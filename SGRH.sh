#!/bin/bash

# SGRH.sh (Versão Revisada)
# Script para configurar o banco de dados PostgreSQL de forma segura e interativa.
#
# USO:
# 1. Certifique-se que o arquivo 'SGRH.sql' está no mesmo diretório.
# 2. Dê permissão de execução: chmod +x SGRH.sh
# 3. Execute o script: ./SGRH.sh
#
# O script irá solicitar as senhas necessárias durante a execução.

# --- Configurações ---
# Saia imediatamente se um comando falhar (muito importante para segurança).
set -e

# Define os nomes. Você pode alterar os padrões aqui se desejar.
TARGET_USER="wagner"
TARGET_DB="sgrh"
SQL_FILE="SGRH.sql"
PG_HOST="localhost"
PG_PORT="5432"
PG_SUPERUSER="postgres"


# --- Verificações Iniciais ---
# Verifica se o comando 'psql' está disponível no sistema.
if ! command -v psql &> /dev/null; then
    echo "ERRO: O cliente 'psql' não foi encontrado."
    echo "Por favor, certifique-se de que o PostgreSQL client está instalado e no PATH do sistema."
    exit 1
fi

# Verifica se o arquivo .sql necessário existe no diretório atual.
if [ ! -f "$SQL_FILE" ]; then
    echo "ERRO: O arquivo de dados '$SQL_FILE' não foi encontrado neste diretório."
    exit 1
fi


# --- Execução Principal ---
echo "--- Iniciando a configuração do banco de dados SGRH ---"
echo "Usuário alvo: $TARGET_USER"
echo "Banco de dados alvo: $TARGET_DB"
echo "--------------------------------------------------------"

# Solicita a senha do superusuário do PostgreSQL de forma segura.
# A flag '-s' esconde o que está sendo digitado.
read -sp "Digite a senha do superusuário do PostgreSQL ($PG_SUPERUSER): " PG_SUPERUSER_PASSWORD
echo # Adiciona uma nova linha para formatação.

# Exporta a senha para que os comandos 'psql' não a peçam novamente.
export PGPASSWORD=$PG_SUPERUSER_PASSWORD

# Testa a conexão como superusuário antes de continuar.
# Redirecionamos a saída e o erro para /dev/null para não poluir o terminal.
if ! psql -U "$PG_SUPERUSER" -h "$PG_HOST" -p "$PG_PORT" -d postgres -c "SELECT 1" > /dev/null 2>&1; then
    echo
    echo "ERRO: Falha ao conectar como superusuário '$PG_SUPERUSER'."
    echo "Verifique se a senha está correta e se o PostgreSQL está aceitando conexões."
    unset PGPASSWORD # Limpa a variável de senha por segurança.
    exit 1
fi
echo "Conexão como '$PG_SUPERUSER' bem-sucedida."
echo

# Verifica se o usuário alvo já existe no banco de dados.
if psql -U "$PG_SUPERUSER" -h "$PG_HOST" -p "$PG_PORT" -d postgres -tc "SELECT 1 FROM pg_roles WHERE rolname='$TARGET_USER'" | grep -q 1; then
    echo "O usuário '$TARGET_USER' já existe. Pulando a etapa de criação."
else
    # Se o usuário não existe, solicita uma senha para ele.
    echo "O usuário '$TARGET_USER' não foi encontrado."
    read -sp "Digite a senha para o NOVO usuário '$TARGET_USER': " TARGET_USER_PASSWORD
    echo
    echo "Criando o usuário '$TARGET_USER' com privilégios de superusuário..."
    # Cria o novo usuário com a senha fornecida.
    psql -U "$PG_SUPERUSER" -h "$PG_HOST" -p "$PG_PORT" -d postgres -c "CREATE ROLE \"$TARGET_USER\" WITH LOGIN PASSWORD '$TARGET_USER_PASSWORD' SUPERUSER;"
    echo "Usuário '$TARGET_USER' criado com sucesso."
fi

# Limpa a senha do superusuário e solicita a senha do usuário alvo para as próximas etapas.
unset PGPASSWORD
read -sp "Para continuar, digite a senha do usuário '$TARGET_USER': " TARGET_USER_PASSWORD
echo
export PGPASSWORD=$TARGET_USER_PASSWORD

echo
echo "Recriando o banco de dados '$TARGET_DB'..."
echo "ATENÇÃO: O banco de dados '$TARGET_DB' existente será APAGADO e recriado!"

# Conecta ao banco 'postgres' padrão para poder apagar e criar o nosso banco de dados alvo.
psql -U "$TARGET_USER" -h "$PG_HOST" -p "$PG_PORT" -d postgres -c "DROP DATABASE IF EXISTS \"$TARGET_DB\";"
psql -U "$TARGET_USER" -h "$PG_HOST" -p "$PG_PORT" -d postgres -c "CREATE DATABASE \"$TARGET_DB\";"
echo "Banco de dados '$TARGET_DB' recriado com sucesso."

echo "Executando o script '$SQL_FILE' no banco de dados '$TARGET_DB'..."
# Finalmente, executa o arquivo .sql no banco de dados recém-criado.
psql -U "$TARGET_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$TARGET_DB" -f "$SQL_FILE"

# Limpa a variável de ambiente da senha por segurança ao final do script.
unset PGPASSWORD

echo
echo "--------------------------------------------------------"
echo "✅ Processo concluído com sucesso!"
echo "O banco de dados '$TARGET_DB' foi criado e populado."
echo "--------------------------------------------------------"
