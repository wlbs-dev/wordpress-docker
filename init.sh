source ./.env

echo "Current dockers running:"
docker ps -a
echo "Do you want to start from scratch? (y/n)"
read -r answer
# answer can be y or Y or enter key
if [ -z "$answer" ]; then
    answer="y"
fi
if [ "$answer" != "${answer#[Yy]}" ] ;then
    echo "Starting from scratch..."
    if [ "$(ls -A ./wordpress)" ]; then
    echo "Directory is not empty, checking if git repo exists in the wordpress directory..."
        if [ -d "./wordpress/.git" ]; then
            cd ./wordpress
            git config --global --add safe.directory /var/www/html
            git remote rename origin upstream
            git remote add origin https://${GITLAB_USERNAME}:${GITLAB_TOKEN}@gitlab.com/${GITLAB_USERNAME}/wordpress-site.git
            git status
            echo "Git repo exists, trying to pull from upstream master..."
            git pull --rebase upstream master
            if [ $? -eq 0 ]; then
                echo "Git pull successful."
            else
                echo "Git pull failed, continuing with script."
            fi
            cd ..
        else
            echo "No Git repo found in the wordpress directory but other files present, exiting script"
            exit 1
        fi
    else
        echo "Directory is empty. Trying to clone repository..."
        if git clone https://${GITLAB_USERNAME}:${GITLAB_TOKEN}@gitlab.com/${GITLAB_USERNAME}/wordpress-site.git ./wordpress; then
            echo "Git clone succeeded."
            cd wordpress
            git config --global --add safe.directory /var/www/html
            git remote rename origin upstream
            git remote add origin https://${GITLAB_USERNAME}:${GITLAB_TOKEN}@gitlab.com/${GITLAB_USERNAME}/wordpress-site.git
            git status
            cd ..
        else
            echo "Git clone failed, exiting script."
            exit 1
        fi
    fi
    # if any error occurs, exit
    set -e
    docker compose down -v --remove-orphans --rmi all
    docker compose up --build
else 
    echo "Not starting from scratch..."
    set -e
    docker compose down --remove-orphans
    docker compose up
fi