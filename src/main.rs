use actix_web::{get, web::{self, service}, App, HttpResponse, HttpServer, Responder};

extern crate dotenv;

use dotenv::dotenv;
use std::{env, process::Output};
use serde::Serialize;
use std::process::Command;

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
    let key_name = "encoded-public-key-".to_owned() + &service_slug;
    let result : Option<String> = redis::cmd("GET").arg(key_name).query(&mut redis_connection).unwrap();

    match result {
        Some(public_key) => return public_key,
        None => return get_and_set_key(service_slug, namespace, &mut redis_connection)
    }
}

fn get_and_set_key(service_slug:String, namespace: String, redis_connection: &mut redis::Connection) -> String {
    let key_name = "encoded-public-key-".to_owned() + &service_slug;
    let recovered_public_key = get_k8s_public_key(service_slug, namespace);
    let key_for_query = recovered_public_key.clone();
    let _query : Option<String> = redis::cmd("SET").arg(key_name).arg(key_for_query).query( redis_connection).expect("Error while recording public key into redis");
    return recovered_public_key;
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
    .bind(("0.0.0.0", 3000))?
    .run()
    .await
}

fn redis_connection() -> redis::Connection {
    let redis_host_name =
        env::var("REDIS_URL").expect("missing environment variable REDIS_URL");

    let redis_password = env::var("REDIS_AUTH_TOKEN").unwrap_or_default();
    let uri_scheme = env::var("REDIS_PROTOCOL").unwrap_or("".to_string());
    let redis_conn_url = format!("{}://:{}@{}", uri_scheme, redis_password, redis_host_name);
    // let redis_conn_url = format!("{}{}", uri_scheme, redis_host_name);

    redis::Client::open(redis_conn_url)
        .expect("Invalid connection URL")
        .get_connection()
        .expect("failed to connect to Redis")
}

fn get_k8s_public_key(service_slug: String, namespace: String) -> String {
    let output = Command::new("kubectl")
            .arg("get")
            .arg("configmaps")
            .arg(format!("fb-{}-config-map", service_slug))
            .arg(format!("--namespace={}", namespace))
            .arg("-o")
            .arg("jsonpath='{.data.ENCODED_PUBLIC_KEY}'")
            .arg(format!("--token={}", env::var("KUBECTL_BEARER_TOKEN").unwrap_or("".to_string())))
            .arg("--ignore-not-found=true")
            .output()
            .expect("failed to execute process");

    let errors = String::from_utf8(output.stderr).unwrap();
    println!("{}",errors);
    let public_key = String::from_utf8(output.stdout).unwrap().replace("'","");
    println!("{}",public_key);
    return public_key;
}
