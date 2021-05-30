# Automation_Project
This script does the below actions
1. Update of the package details and the package list
2. Install the apache2 package if it is not already installed
3. Start apache2 service if not running
4. Enable apache2 service if not enabled
5. Create a tar archive of apache2 access logs and error logs and place the tar into the /tmp/ directory with current timestamp
6. Upload tar file to S3 bucket
