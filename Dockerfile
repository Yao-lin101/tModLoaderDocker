FROM steamcmd/steamcmd:alpine-3

# Install prerequisites
RUN apk update \
 && apk add --no-cache bash curl tmux libstdc++ libgcc icu-libs \
 && rm -rf /var/cache/apk/*

# Fix 32 and 64 bit library conflicts
RUN mkdir /steamlib \
 && mv /lib/libstdc++.so.6 /steamlib \
 && mv /lib/libgcc_s.so.1 /steamlib
ENV LD_LIBRARY_PATH /steamlib

# Set a specific tModLoader version, defaults to the latest Github release
ARG TML_VERSION

# Create tModLoader user and drop root permissions
ARG UID
ARG GID
RUN addgroup -g $GID tml \
 && adduser tml -u $UID -G tml -h /home/tml -D

USER tml
ENV USER tml
ENV HOME /home/tml
WORKDIR $HOME

# Update SteamCMD and verify latest version
RUN steamcmd +quit

# Copy local files
COPY --chown=tml:tml manage-tModLoaderServer.sh .
COPY --chown=tml:tml tModLoader.zip .

# Make management script executable
RUN chmod +x manage-tModLoaderServer.sh

# Extract tModLoader.zip and move files
RUN unzip tModLoader.zip -d server/ && rm tModLoader.zip

EXPOSE 7777

ENTRYPOINT [ "./manage-tModLoaderServer.sh", "docker", "--folder", "/home/tml/.local/share/Terraria/tModLoader" ]
