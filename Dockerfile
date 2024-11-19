# Dockerfile
FROM alpine:latest

# Install dependencies: jq (for JSON parsing), bash, and moreutils (for sponge)
RUN apk add --no-cache bash jq moreutils

# Copy the script into the image
COPY portupdate.sh /update_port/portupdate.sh

# Make the script executable
RUN chmod +x /update_port/portupdate.sh

# Set the entrypoint to run the script
ENTRYPOINT ["/update_port/portupdate.sh"]
