# Mount Azure file
# sudo apt-get install cifs-utils
# mkdir /azurebackups
sudo mount -t cifs //sql2017builddemo.file.core.windows.net/backups /azurebackups -o vers=3.0,username=sql2017builddemo,password=XVjLIwjTTDRtNuK5mXRfuRz+R2oq+e9arnBBVEoMY38cV+WCF6gl415f5hY5n5NpKAFMpEOP7rjVnnoHHZzAsg==,dir_mode=0777,file_mode=0777
 
printf "\n*** Pull and run microsoft/mssql-server-linux Docker image from Docker Hub ***\n"
docker pull microsoft/mssql-server-linux
docker run --name sanitation-station -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=//build2017' -p 1433:1433 -v /azurebackups:/azurebackups -d microsoft/mssql-server-linux 
docker ps
sleep 10

printf "\n*** Restoring production database into sanitation environment ***\n"
sqlcmd -Usa -P//build2017 -i ../sql/Restore_Production_Database_as_Development.sql

printf "\n*** Docker commit to create pre-production image ***\n"
docker commit sanitation-station db-pre-prod:latest
docker images

printf "\n*** Sanitizing production data for development use ***\n"
printf "\n*** Unsanitized data: ***\n"
sqlcmd -Usa -P//build2017 -Q"SELECT TOP 10 FirstName, LastName FROM ContosoUniversity.dbo.Person;"
sqlcmd -Usa -P//build2017 -i ../sql/Sanitize_Production_Database_for_Dev_use.sql
printf "\n*** Sanitized data (using Norwegian encryption): ***\n"
sqlcmd -Usa -P//build2017 -Q"SELECT TOP 10 FirstName, LastName FROM ContosoUniversity.dbo.Person;"

printf "\n*** Docker commit to create big dev image ***\n"
docker commit sanitation-station db-dev-big-tmp:latest
docker images

printf "\n*** Shrinking small dev database ***\n"
sqlcmd -Usa -P//build2017 -i ../sql/Shrink_Development_Database_Small.sql

printf "\n*** Docker commit to create small dev image ***\n"
docker commit sanitation-station db-dev-small-tmp:latest
docker images
docker rm -f sanitation-station

printf "\n*** Flattening small image to reduce size ***\n"
docker run --name tmp-small -d db-dev-small-tmp
docker export tmp-small | docker import - db-dev-small:latest
docker rm -f tmp-small
docker rmi db-dev-small-tmp

printf "\n*** Flattening large image to reduce size ***\n"
docker run --name tmp-big -d db-dev-big-tmp
docker export tmp-big | docker import - db-dev-big:latest
docker rm -f tmp-big
docker rmi db-dev-big-tmp

printf "\n*** Final list of images ***\n"
docker images

printf "\n*** Build and Publish images to registry ***\n"
docker build ./db-dev-small -t db-dev-small:latest
docker build ./db-dev-big -t db-dev-big:latest

docker tag db-dev-small:latest ContosoRegistry.azurecr.io/db-dev-small:latest
#docker push ContosoRegistry.azurecr.io/db-dev-small:latest

docker tag db-dev-big:latest ContosoRegistry.azurecr.io/db-dev-big:latest
#docker push ContosoRegistry.azurecr.io/db-dev-big:latest

docker tag db-pre-prod:latest ContosoRegistry.azurecr.io/db-pre-prod:latest
#docker push ContosoRegistry.azurecr.io/db-pre-prod:latest

#docker run --name db-big -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=//build2017' -p 1433:1433 -d db-dev-big /opt/mssql/bin/sqlservr
#docker run --name db-small -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=//build2017' -p 1433:1433 -d db-dev-small /opt/mssql/bin/sqlservr















