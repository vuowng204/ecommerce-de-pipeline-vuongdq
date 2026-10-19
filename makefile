.PHONY: help up down logs psql seed reset-db tf-init tf-plan tf-apply tf-destroy

DC := docker compose -f docker/docker-compose.yml

help:
	@echo "Commands:"
	@echo "  make up           - Start Postgres"
	@echo "  make down         - Stop Postgres"
	@echo "  make reset-db     - Drop volume and restart Postgres (XÓA HẾT DATA)"
	@echo "  make seed         - Seed data (idempotent)"
	@echo "  make seed-reset   - Reset + seed"
	@echo "  make psql         - Open psql shell"
	@echo "  make tf-apply     - terraform apply"
	@echo "  make tf-destroy   - terraform destroy"

up:
	$(DC) up -d --wait
	@echo " Postgres is ready!!"
down:
	$(DC) down

reset-db:
	$(DC) down -v
	$(DC) up -d

logs:
	$(DC) logs -f postgres

psql:
	$(DC) exec postgres psql -U admin -d shop

load-olist:
	uv run python -m scripts.load_olist_csv 

olist-summary:
	@docker compose -f docker/docker-compose.yml exec postgres psql -U shop -d shop -c "\
	SELECT 'customers' AS tbl, COUNT(*) FROM raw_olist.customers UNION ALL \
	SELECT 'orders', COUNT(*) FROM raw_olist.orders UNION ALL \
	SELECT 'order_items', COUNT(*) FROM raw_olist.order_items UNION ALL \
	SELECT 'order_payments', COUNT(*) FROM raw_olist.order_payments UNION ALL \
	SELECT 'order_reviews', COUNT(*) FROM raw_olist.order_reviews UNION ALL \
	SELECT 'products', COUNT(*) FROM raw_olist.products UNION ALL \
	SELECT 'sellers', COUNT(*) FROM raw_olist.sellers UNION ALL \
	SELECT 'geolocation', COUNT(*) FROM raw_olist.geolocation UNION ALL \
	SELECT 'category_translation', COUNT(*) FROM raw_olist.product_category_name_translation;"

tf-init:
	cd infra && terraform init

tf-plan:
	cd infra && terraform plan

tf-apply:
	cd infra && terraform apply

tf-destroy:
	cd infra && terraform destroy
ingest:
	uv run python ingestion/pipeline.py