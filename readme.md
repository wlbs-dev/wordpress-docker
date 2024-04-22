### Docker Setup for New WordPress Sites

This repository provides a Docker-based setup for quickly deploying new WordPress sites. By following these steps, you'll have a WordPress environment up and running in no time.

#### Prerequisites

- Installed docker & docker-compose and running on your system before proceeding with the setup.
- Installed git

#### Installation Steps

1. **Clone the Repository**: 
   ```sh
   git clone https://github.com/wlbs-dev/wordpress-docker.git
   ```
   
2. **Navigate to the Directory**:
   ```sh
   cd wordpress-docker
   ```

3. **Create Environment File**: 
   Make an environment file named `.env` inside the `wordpress-docker` directory. Populate it with the following variables:

   ```sh
   # Environment Variables
   # Database Configuration
   WORDPRESS_DB_HOST=db                  # Hostname of the MySQL database
   WORDPRESS_DB_PORT=3306                # Port of the MySQL database
   WORDPRESS_DB_USER=                    # Username for accessing the WordPress database
   WORDPRESS_DB_PASSWORD=                # Password for accessing the WordPress database
   WORDPRESS_DB_NAME=                    # Name of the WordPress database
   MYSQL_ROOT_PASSWORD=                  # Root password for the MySQL database

   # WordPress Configuration
   WORK_DIR=/var/www/html                # WordPress working directory
   THEME_NAME=                           # Name of the active WordPress theme
   BACKUP_THEME_NAME=                    # Name of the theme used for backups (if different)
   DONT_USE_BACKUP=                      # Flag to disable backup functionality (if set to any value)
   URL1_TO_REPLACE=http://localhost:8000/  # Placeholder URL for search and replace
   URL2_TO_REPLACE=                      # Additional placeholder URL for search and replace
   URL3_TO_REPLACE=                      # Additional placeholder URL for search and replace
   URL4_TO_REPLACE=                      # Additional placeholder URL for search and replace
   URL=https://localhost:8000/           # Main URL of the WordPress site
   EXPOSE_PORT=8000                      # Port to expose WordPress (e.g., for accessing the site)

   # WordPress Site Configuration
   TITLE=                                # Title of the WordPress site
   ADMIN_USER=admin_user                 # Admin username for WordPress login
   ADMIN_PASSWORD=                       # Admin password for WordPress login
   ADMIN_EMAIL=admin.mail@gmail.com      # Admin email address for WordPress

   # Miscellaneous Configuration
   TABLE_PREFIX=                         # Prefix for WordPress database tables (if desired)
   DOCKER_NAME=                          # Name for the Docker container
   S3_BACKUP_LOCATION=  # Location for storing backups in AWS S3
   AWS_ACCESS_KEY_ID=                    # AWS Access Key ID for S3 backup storage
   AWS_SECRET_ACCESS_KEY=                # AWS Secret Access Key for S3 backup storage
   FULL_BACKUP_INTERVAL=1800             # Interval for full backups in seconds
   ```
   Fill in the values for each variable according to your setup.

4. **Set Up Backups Folder**:
   Inside the `wordpress-docker` directory, create a folder named `backups`. Within this folder, create an empty SQL file named `backup.sql`.

5. **Ensure Docker is Running**:
   Before proceeding further, ensure that Docker is up and running on your system.

6. **Run Docker Compose**:
   Execute the following command to start the Docker containers:

   ```sh
   docker compose up --build
   ```

#### Usage

Once the Docker containers are up and running, you can access your WordPress site by navigating to the specified URL in your browser. 

#### Backup Configuration

This setup includes backup functionality. The `backups` folder is where your database backups will be stored. Ensure that you have configured the `S3_BACKUP_LOCATION`, `AWS_ACCESS_KEY_ID`, and `AWS_SECRET_ACCESS_KEY` variables in the `.env` file for automated backups to an AWS S3 bucket.

#### Notes

- Adjust the `EXPOSE_PORT` variable in the `.env` file if you want to expose WordPress on a different port.
- Customize other variables in the `.env` file according to your specific requirements.

#### Support

For any issues or inquiries, please reach out to [WLBS Dev Team](https://github.com/wlbs-dev).