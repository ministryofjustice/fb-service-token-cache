use actix_web::{get, web::{self, service}, App, HttpResponse, HttpServer, Responder};

extern crate dotenv;

use dotenv::dotenv;
use std::env;
use serde::Serialize;

#[derive(Serialize)]
struct Payload {
    token: String
}

#[get("/health")]
async fn health() -> impl Responder {
    HttpResponse::Ok().body("Healthy")
}

#[get("/readiness")]
async fn readiness() -> impl Responder {
    HttpResponse::Ok().body("Ready")
}

#[get("/service/v2/{service_slug}")]
async fn service_public_key(path: web::Path<String>) -> impl Responder {
    let namespace = env::var("KUBECTL_SERVICES_NAMESPACE").expect("service namespace is not set");
    let service_slug = path.into_inner();
    let public_key = get_public_key(service_slug.to_string(), namespace);
    let payload = Payload { token: public_key };

    HttpResponse::Ok().json(payload)
}

#[get("/v3/applications/{service_slug}/namespaces/{namespace}")]
async fn application_public_key(path: web::Path<(String, String)>) -> impl Responder {
    let (service_slug, namespace) = path.into_inner();
    let public_key = get_public_key(service_slug, namespace);
    let payload = Payload { token: public_key };

    HttpResponse::Ok().json(payload)
}

fn get_public_key(service_slug: String, namespace: String) -> String {
    let mut redis_connection = redis_connection();

    let key_name = format!("encoded-pubic-key-{}", service_slug);
    let mut public_key: String = redis::cmd("GET")
        .arg(key_name)
        .query(&mut redis_connection)
        .expect(format!("failed to execute GET for {}", key_name).as_str());

    if public_key.is_empty() {
        public_key = get_k8s_public_key(service_slug, namespace);

        if public_key.is_empty() {
            return "Key not found in Redis or in K8s".to_string();
        } else {
            let _result: String = redis::cmd("SET")
                .arg(key_name)
                .arg(public_key)
                .query(&mut redis_connection)
                .expect(format!("failed to execute SET for {}", key_name).as_str());

            return public_key;
        }
    } else {
        return public_key;
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv().ok();

    HttpServer::new(|| {
        App::new()
            .service(health)
            .service(readiness)
            .service(service_public_key)
            .service(application_public_key)
    })
    .bind(("127.0.0.1", 3000))?
    .run()
    .await
}

fn redis_connection() -> redis::Connection {
    let redis_host_name =
        env::var("REDIS_URL").expect("missing environment variable REDIS_URL");

    let redis_password = env::var("REDIS_AUTH_TOKEN").unwrap_or_default();
    let uri_scheme = env::var("REDIS_PROTOCOL").unwrap_or("".to_string());
    let redis_conn_url = format!("{}://:{}@{}", uri_scheme, redis_password, redis_host_name);
    redis::Client::open(redis_conn_url)
        .expect("Invalid connection URL")
        .get_connection()
        .expect("failed to connect to Redis")
}

fn get_k8s_public_key(service_slug: String, namespace: String) -> String {
    "something".to_string()
}
