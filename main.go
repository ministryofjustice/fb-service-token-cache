package main

import (
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-redis/redis"
	"github.com/joho/godotenv"
)

var dotenvErr = godotenv.Load()

var redisClient *redis.Client
var url string

func init() {
	url = fmt.Sprintf("%s:%s@%s:6379", os.Getenv("REDIS_PROTOCOL"), os.Getenv("REDIS_AUTH_TOKEN"), os.Getenv("REDIS_URL"))
	opt, err := redis.ParseURL(url)
	if err != nil {
		fmt.Println(err)
	}
	redisClient = redis.NewClient(opt)
}

func main() {
	r := gin.Default()
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "healthy",
		})
	})

	r.GET("/readiness", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "ready",
		})
	})

	r.GET("/service/v2/:serviceSlug", func(c *gin.Context) {
		serviceSlug := c.Params.ByName("serviceSlug")
		namespace := os.Getenv("KUBECTL_SERVICES_NAMESPACE")
		publicKey := getPublicKey(serviceSlug, namespace)

		payload := gin.H{"token": publicKey}
		c.JSON(http.StatusOK, payload)
	})

	r.GET("/v3/applications/:serviceSlug/namespaces/:namespace", func(c *gin.Context) {
		serviceSlug := c.Params.ByName("serviceSlug")
		namespace := c.Params.ByName("namespace")
		publicKey := getPublicKey(serviceSlug, namespace)

		payload := gin.H{"token": publicKey}
		c.JSON(http.StatusOK, payload)
	})
	r.Run(":3000")
}

func getPublicKey(serviceSlug, namespace string) string {
	keyName := fmt.Sprintf("encoded-public-key-%s", serviceSlug)
	publicKey := getPublicKeyRedis(keyName)

	if publicKey == "" {
		fmt.Println("No key found in Redis")

		publicKey = getPublicKeyK8s(serviceSlug, namespace)
		if publicKey == "" {
			fmt.Println("No key found in K8S")
		} else {
			fmt.Println("Key found in K8S")
			redisClient.Set(keyName, publicKey, time.Hour)
		}
	} else {
		fmt.Println("Key found in Redis")
	}

	return strings.Trim(publicKey, `'`)
}

func getPublicKeyRedis(keyName string) string {
	publicKey, err := redisClient.Get(keyName).Result()
	if err != nil {
		fmt.Println(err)
	}

	return publicKey
}

func getPublicKeyK8s(serviceSlug, namespace string) string {
	k8sExecPath, err := exec.LookPath("kubectl")
	if err != nil {
		fmt.Println(err)
	}

	command := exec.Command(
		k8sExecPath,
		"get",
		"configmaps",
		fmt.Sprintf("fb-%s-config-map", serviceSlug),
		fmt.Sprintf("--namespace=%s", namespace),
		"-o",
		"jsonpath='{.data.ENCODED_PUBLIC_KEY}'",
		fmt.Sprintf("--token=%s", os.Getenv("KUBECTL_BEARER_TOKEN")),
		"--ignore-not-found=true",
	)
	out, err := command.Output()

	if err != nil {
		fmt.Println(err)
	}

	return string(out)
}
