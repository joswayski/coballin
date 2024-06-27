# Use a base image that supports x86 architecture
FROM --platform=linux/amd64 ubuntu:20.04

# Install GNUCobol
RUN apt-get update && apt-get install -y gnucobol

# Create the application directory
RUN mkdir /app

# Copy your COBOL source code into the image
COPY ./railway.cbl ./

EXPOSE 8080

# Compile your COBOL program
RUN cobc -x -free -o /app/railway ./railway.cbl

# Set permissions for the executable
RUN chmod +x /app/railway

# Set the entry point for the container
CMD ["/app/railway"]
