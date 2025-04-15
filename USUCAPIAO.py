import asana
from asana.rest import ApiException
from dotenv import load_dotenv
import os
import pandas as pd
from datetime import datetime, timedelta, timezone
from pathlib import Path
import sys

# Verifica se está rodando como executável PyInstaller
if getattr(sys, 'frozen', False):
    # Se for executável, usa a pasta temporária do PyInstaller
    base_dir = sys._MEIPASS
else:
    # Se for desenvolvimento, usa a pasta do script
    base_dir = os.path.dirname(__file__)

# Caminho completo para o .env
env_path = Path(base_dir) / ".env"
load_dotenv(env_path)  # Carrega o arquivo .env

# Variaveis ambientais
ASANA_ACCESS_TOKEN = os.getenv("ASANA_ACCESS_TOKEN")
PROJECT_GID = os.getenv("USUCAPIAO_GID")

configuration = asana.Configuration()
configuration.access_token = ASANA_ACCESS_TOKEN
api_client = asana.ApiClient(configuration)

# Instâncias das APIs
tasks_api_instance = asana.TasksApi(api_client)
sections_api_instance = asana.SectionsApi(api_client)

# Obtém a ordem das seções
print("Obtendo seções do projeto...")
sections_response = sections_api_instance.get_sections_for_project(PROJECT_GID, {})
# sections_response = sections_api_instance.get_sections_for_project(PROJECT_GID)
section_order = {
    section['gid']: {
        'name': section['name'],
        'position': index + 1  # Começa em 1
    }
    for index, section in enumerate(sections_response)
}

# Parâmetros para buscar tarefas
modified_since_date = (datetime.now(timezone.utc) - timedelta(days=1000)).strftime("%Y-%m-%dT%H:%M:%S.000Z")
opts = {
    'modified_since': modified_since_date,
    'limit': 100,
    'opt_fields': "assignee.name,completed,completed_at,completed_by.name,created_at,created_by.name,due_on,modified_at,name,gid,memberships.section.name,memberships.section.gid,memberships.project.gid,projects.name,resource_subtype,tags.name,permalink_url"
}

try:
    tasks_data = []
    offset = None
    
    print("Processando tarefas...")
    while True:
        if offset:
            opts['offset'] = offset

        api_response = tasks_api_instance.get_tasks_for_project(PROJECT_GID, opts)
        
        for task in api_response:
            task_gid = task.get('gid', '')
            task_name = task.get('name', '')
            is_completed = task.get('completed', False)
            
            # Processa membroships para obter seção
            section_info = {'name': '', 'gid': '', 'position': ''}
            memberships = task.get('memberships', [])
            for membership in memberships:
                if membership.get('project', {}).get('gid') == PROJECT_GID:
                    section_gid = membership.get('section', {}).get('gid', '')
                    section_info = {
                        'name': membership.get('section', {}).get('name', ''),
                        'gid': section_gid,
                        'position': section_order.get(section_gid, {}).get('position', '')
                    }
                    break

            # Determina a situação baseada na posição da seção e status de conclusão
            # "Realizado" (valor padrão)
            situacao = "Realizado"  # Valor padrão
            
            if section_info['position'] == 1:  # ESTUDO PRÉVIO
                situacao = "A Realizar"
            elif 2 <= section_info['position'] <= 14 or (section_info['position'] == 18): # Seções 2-14 ou 18
                situacao = "Em Execução"
            elif section_info['position'] in [20, 22] and is_completed:  # FINALIZADO E CONCLUÍDO
                situacao = "Finalizado"
            elif section_info['position'] in [20, 22] and not is_completed:  # FINALIZADO MAS NÃO CONCLUÍDO
                situacao = "Finalizado sem ser Concluído"

            # Cria o dicionário com todas as informações
            task_info = {
                "Responsável": task.get('assignee', {}).get('name', '') if task.get('assignee') else '',
                "Status": "Concluído" if is_completed else "Pendente",
                "Data de Conclusão": task.get('completed_at', ''),
                "Concluido Por": task.get('completed_by', {}).get('name', '') if task.get('completed_by') else '',
                "Data de Criação": task.get('created_at', ''),
                "Criado Por": task.get('created_by', {}).get('name', '') if task.get('created_by') else '',
                "Previsão de Conclusão": task.get('due_on', ''),
                "Última Modificação": task.get('modified_at', ''),
                "GID": task_gid,
                "Tarefa": task_name,
                "Seção": section_info['name'],
                "Ordem da Seção": section_info['position'],
                "Projeto": next((p.get('name', '') for p in task.get('projects', []) if p.get('gid') == PROJECT_GID), ''),
                "resource_subtype": task.get('resource_subtype', ''),
                "Tags": ", ".join([tag.get('name', '') for tag in task.get('tags', [])]),
                "Link": task.get('permalink_url', ''),
                "Situação": situacao
            }
            tasks_data.append(task_info)

        if hasattr(api_response, 'next_page') and api_response.next_page:
            offset = api_response.next_page.offset
        else:
            break

    # Cria e salva o DataFrame
    df = pd.DataFrame(tasks_data)
    output_file = "USUCAPIAO_tarefas.xlsx"
    output_path = "\\SERVIDOR\Dashboard\Fonte de dados interna\USUCAPIAO_tarefas.xlsx"
    df.to_excel(output_path, index=False, engine='openpyxl')
    print(f"Relatório gerado com sucesso: {output_file}")

except ApiException as e:
    print(f"Erro na API: {e}")
except Exception as e:
    print(f"Erro inesperado: {e}")