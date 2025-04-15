import subprocess
import logging
import os
import sys

# Define o diretório do log na mesma pasta do .exe
if getattr(sys, 'frozen', False):
    BASE_DIR = os.path.dirname(sys.executable)
else:
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))

LOG_FILE = os.path.join(BASE_DIR, "log_automacao.txt")

# Configuração do log
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

if logger.hasHandlers():
    logger.handlers.clear()

file_handler = logging.FileHandler(LOG_FILE, encoding="utf-8")
file_handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
logger.addHandler(file_handler)

stream_handler = logging.StreamHandler()
stream_handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
logger.addHandler(stream_handler)

def log_e_print(mensagem, nivel=logging.INFO):
    if nivel == logging.ERROR:
        logger.error(mensagem)
    else:
        logger.info(mensagem)

log_e_print("="*50)
log_e_print("Iniciando execução da Automação")

# Lista de executáveis
EXECUTAVEIS = ["Projeto1.exe", "Projeto2.exe", "Projeto3.exe", "Projeto4.exe"]

for EXECUTAVEL in EXECUTAVEIS:
    try:
        log_e_print(f"Iniciando {EXECUTAVEL}...")
        resultado = subprocess.run([EXECUTAVEL], capture_output=True, text=True, encoding="utf-8", errors="replace")

        mensagem_saida = f"{EXECUTAVEL} finalizado com código {resultado.returncode}"
        log_e_print(mensagem_saida)

        if resultado.stdout:
            log_e_print(f"Saída de {EXECUTAVEL}:\n{resultado.stdout.strip()}")

        if resultado.stderr:
            log_e_print(f"Erro de {EXECUTAVEL}:\n{resultado.stderr.strip()}", nivel=logging.ERROR)

    except Exception as e:
        log_e_print(f"Erro ao executar {EXECUTAVEL}: {str(e)}", nivel=logging.ERROR)

log_e_print(f"Log criado em: {LOG_FILE}")
