server:
	bundle exec rake webpack:run& bundle exec thin start --port=3000
run:
	bundle exec thin start --port=3000
