# build with
# docker build --force-rm -t my-airflow-pipeline:${USER} .
FROM rocker/geospatial

USER rstudio
WORKDIR "/home/rstudio"

# COPY --chown="rstudio:${NB_GID}" "install.R" "/tmp/"
COPY "install.R" "/tmp/"
RUN Rscript /tmp/install.R

CMD ["bash"]
