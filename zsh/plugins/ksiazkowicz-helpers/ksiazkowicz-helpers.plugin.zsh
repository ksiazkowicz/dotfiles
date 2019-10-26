function docker-env() {
    eval $(docker-machine env $1)
}

function generate-djangosecret-key() {
    python manage.py shell -c "from django.core.management import utils; print(utils.get_random_secret_key())"
}

function grep-kill() {
    kill $(ps aux | grep $* | awk '{print $2}') -f 2> /dev/null
}

