### Docker Setup for New WordPress Sites

This repository provides a Docker-based setup for quickly deploying new WordPress sites. By following these steps, you'll have a WordPress environment up and running in no time.

#### Prerequisites

- Installed docker & docker-compose and running on your system before proceeding with the setup.
- Installed git

#### Installation Steps

1. **Clone the Repository**: 
   ```
   git clone https://github.com/wlbs-dev/wordpress-docker.git
   ```
   
2. **Navigate to the Directory**:
   ```
   cd wordpress-docker
   ```

3. **Create Environment File**: 
   Make an environment file named `.env` inside the `wordpress-docker` directory. Populate it with the following variables:
   ```
   MYSQL_ROOT_PASSWORD=
   WORDPRESS_DB_NAME=
   WORDPRESS_DB_USER=
   WORDPRESS_DB_PASSWORD=
   WORDPRESS_DB_HOST=
   TABLE_PREFIX=
   URL=
   S3_BACKUP_LOCATION=
   AWS_ACCESS_KEY_ID=
   AWS_SECRET_ACCESS_KEY=
   EXPOSE_PORT=443
   ```
   Fill in the values for each variable according to your setup.

4. **Set Up Backups Folder**:
   Inside the `wordpress-docker` directory, create a folder named `backups`. Within this folder, create an empty SQL file named `backup.sql`.

5. **Ensure Docker is Running**:
   Before proceeding further, ensure that Docker is up and running on your system.

6. **Run Docker Compose**:
   Execute the following command to start the Docker containers:
   ```
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