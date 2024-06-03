process NANOLYSE {
    tag "$meta.id"

    conda "bioconda::nanolyse=1.2.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/nanolyse:1.2.1--pyhdfd78af_0' :
        'biocontainers/nanolyse:1.2.1--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(reads)
    path nanolyse_db

    output:
    tuple val(meta), path("${meta.id}_nanolyse.fastq.gz"), emit: reads
    path  "${meta.id}_nanolyse.log"                      , emit: log
    path "versions.yml"                                  , emit: versions

    script:
    """
    cat ${reads} | NanoLyse --reference $nanolyse_db | gzip > ${meta.id}_nanolyse.fastq.gz
    echo "NanoLyse reference: $params.lambda_reference" >${meta.id}_nanolyse.log
    cat ${reads} | echo "total reads before NanoLyse: \$((`wc -l`/4))" >>${meta.id}_nanolyse.log
    gunzip -c ${meta.id}_nanolyse.fastq.gz | echo "total reads after NanoLyse: \$((`wc -l`/4))" >> ${meta.id}_nanolyse.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        NanoLyse: \$(NanoLyse --version | sed -e "s/NanoLyse //g")
    END_VERSIONS
    """
}
