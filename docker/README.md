## Comandos Docker Úteis

-   Para Debug, caso algum container não esteja subindo.<br>
    `docker ps -la --no-trunc`<hr>
-   Para visualizar logs de um container que não subiu. <br>
    `docker logs $container_id`<hr>
-   Para fazer build da imagem docker<br>
    `docker compose build`<hr>
-   Para executar a imagem docker<br>
    `docker compose up -d`<hr>
-   Para entrar dentro de um container<br>
    `docker compose exec -it $container_id bash`<hr>
