### General

- [-1] La pipeline no es ejecutable tal cual está

### pipeline.sh

- [-0.5] L2: La instalación de software debería ser hecha a través de un ambiente de conda
  en archivo aparte
- [-0.5] L11: Las rutas de los ficheros deberían ser extraídas con algo como
  `$(cat data/urls)`
- [-0.5] L20: La descompresión debería ser hecha en `download`.sh
- [-0.5] L22: El filtrado debería ser hecho en `download`.sh
- [-0.5] L22: Nombre de comando erróneo `seqtik -> seqkit`

### merge_fastqs.sh

- [-0.5] L9: Deberían utilizarse nombres de archivo más genéricos para que el
  script fuera más adaptable a otros nombres de archivo (e.g. `cat $1/$3*.fastq.gz > $2/$3.fastq.gz`)
