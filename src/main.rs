use actix_web::{get, web, App, HttpResponse, HttpServer, Responder};

extern crate dotenv;

use dotenv::dotenv;
use std::env;

#[get("/health")]
async fn health() -> impl Responder {
    HttpResponse::Ok().body("Healthy")
}

#[get("/readiness")]
async fn readiness() -> impl Responder {
    HttpResponse::Ok().body("Ready")
}

#[get("/service/v2/{service_slug}")]
async fn service_public_key(path: web::Path<&str>) -> impl Responder {
    let service_slug = path.into_inner();
    let namespace = $KUBECTL_SERVICES_NAMESPACE;
    let public_key = get_public_key(service_slug, "formbuilder-services-test-production");

    HttpResponse::Ok().body(format!("{service_slug}"))
}

#[get("/v3/applications/{service_slug}/namespaces/{namespace}")]
async fn application_public_key(path: web::Path<(&str, &str)>) -> impl Responder {
    let (service_slug, namespace) = path.into_inner();
    let public_key = get_public_key(service_slug, namespace);

    HttpResponse::Ok().body(format!("{service_slug} - {namespace}"))
}

fn get_public_key<'a>(service_slug: &'a str, namespace: &'a str) -> &'a str {
    return "some string"
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
