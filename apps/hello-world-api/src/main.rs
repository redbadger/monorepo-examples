use actix_web::{middleware, web, App, HttpRequest, HttpServer};
use env_logger::Env;

async fn greet(_req: HttpRequest) -> &'static str {
    "Hello world!"
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::Builder::from_env(
        Env::default().default_filter_or("actix_server=info,actix_web=info"),
    )
    .init();

    HttpServer::new(|| {
        App::new()
            .wrap(middleware::Compress::default())
            .wrap(middleware::Logger::default())
            .route("/", web::get().to(greet))
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}

#[cfg(test)]
mod tests {
    use super::*;

    use actix_web::{test, App};

    #[actix_web::test]
    async fn test_index() {
        let app = test::init_service(App::new().route("/", web::get().to(greet))).await;
        let req = test::TestRequest::get().to_request();

        let resp = test::call_service(&app, req).await;
        assert!(resp.status().is_success());
    }
}
