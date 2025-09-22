# Archalyzer – Threat Modeling from Architecture Diagrams

Archalyzer é um projeto de IA que interpreta automaticamente diagramas de arquitetura de sistemas (ex.: usuários, servidores, bancos de dados, APIs) para gerar um Relatório de Modelagem de Ameaças baseado na metodologia STRIDE, além de buscar vulnerabilidades relacionadas a cada componente e sugerir contramedidas.

Este repositório contém:
- Backend em Python com FastAPI para análise de imagens de diagramas utilizando modelos multimodais (OpenAI GPT‑4o, fallback Gemini) e retorno em JSON estruturado.
- App Flutter para captura/envio de imagens (ou upload) e visualização do relatório.


## Objetivos
- Desenvolver uma IA que interprete automaticamente um diagrama de arquitetura de sistema, identificando os componentes (ex.: usuários, servidores, bases de dados, APIs, etc.).
- Gerar um Relatório de Modelagem de Ameaças baseado na metodologia STRIDE.
- Construir ou buscar um dataset contendo imagens de Arquitetura de Software.
- Anotar o dataset para treinar um modelo supervisionado capaz de identificar componentes de arquitetura.
- Treinar o modelo.
- Desenvolver um sistema que busque vulnerabilidades por componente e proponha contramedidas específicas para cada ameaça.


## Estrutura do Repositório
- `hackaton/backend/`
  - `main.py`: serviço FastAPI com endpoints para análise do diagrama e healthcheck dos providers de IA.
  - `requirements.txt`: dependências Python (FastAPI, Uvicorn, Pillow, OpenAI SDK, etc.).
- `hackaton/app/archalyzer/`
  - `pubspec.yaml`: manifesto do app Flutter (nome do app, dependências, assets).
  - `lib/`
    - `core/service_locator.dart`: configuração de `Dio`, `BASE_URI` e `AUTH_TOKEN` via `.env`.
    - `main.dart`: bootstrap do app e carregamento do `.env` via `flutter_dotenv`.


## Pré‑requisitos
- Python 3.10+ (recomendado)
- Flutter SDK 3.22+ e Dart 3.8+
- Chaves de API:
  - OpenAI: variável de ambiente `OPENAI_API_KEY`
  - Google (Gemini, compatível via OpenAI endpoint): variável de ambiente `GOOGLE_API_KEY`


## Backend (Python FastAPI)
Diretório: `hackaton/backend/`

### Dependências
Instale em um ambiente virtual de sua preferência:

```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r hackaton/backend/requirements.txt
```

### Variáveis de Ambiente
- `OPENAI_API_KEY`: chave para usar o GPT‑4o.
- `GOOGLE_API_KEY`: chave para fallback Gemini (via interface compatível OpenAI).
- `API_AUTH_TOKEN`: token estático para autenticação Bearer nas rotas do backend.

Você pode criar um arquivo `.env` no diretório `hackaton/backend/` para facilitar o desenvolvimento local:

```env
OPENAI_API_KEY=sk-...
GOOGLE_API_KEY=...
API_AUTH_TOKEN=dev-token-123
```

### Executando o servidor

```bash
uvicorn hackaton.backend.main:app --host 0.0.0.0 --port 8000 --reload
```

### Endpoints
- `POST /analyze-diagram`
  - Autenticação: Bearer Token (header `Authorization: Bearer <API_AUTH_TOKEN>`)
  - Body: `multipart/form-data` com arquivo `image`
  - Retorno: JSON com título, provedor de cloud, descrição, e lista de componentes com ameaça STRIDE mais crítica e mitigação.

- `GET /health/ai-services`
  - Autenticação: Bearer Token
  - Retorno: disponibilidade de `openai` e `gemini`.

### Exemplo (curl)

```bash
curl -X POST \
  -H "Authorization: Bearer dev-token-123" \
  -F "image=@/caminho/para/diagrama.png" \
  http://localhost:8000/analyze-diagram
```


## App Flutter (archalyzer)
Diretório: `hackaton/app/archalyzer/`

### Dependências

```bash
cd hackaton/app/archalyzer
flutter pub get
```

### Arquivo .env do Flutter
O app usa `flutter_dotenv` e espera a presença de `.env` (mapeado como asset em `pubspec.yaml`). Crie `hackaton/app/archalyzer/.env` com:

```env
# URL base do backend FastAPI
BASE_URI=http://10.0.2.2:8000  # Android Emulator usa 10.0.2.2 para localhost
# Token de autenticação para o backend (deve combinar com API_AUTH_TOKEN do backend)
AUTH_TOKEN=dev-token-123
```

No iOS Simulator, você pode usar `http://localhost:8000`. Em dispositivos físicos, use o IP da sua máquina.

### Executando

```bash
flutter run
```

O app carrega o `.env`, configura `Dio` com `BASE_URI` e envia o token Bearer (`AUTH_TOKEN`) automaticamente ao backend (ver `lib/core/service_locator.dart`).


## Metodologia STRIDE no Projeto
O backend orienta o modelo multimodal a:
- Identificar componentes específicos (ex.: "Application Load Balancer", "Amazon RDS").
- Selecionar a ameaça STRIDE mais crítica por componente: Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege.
- Classificar o nível de ameaça: High, Medium, Low, None.
- Sugerir mitigações acionáveis e específicas.

O retorno é sempre um JSON válido, adequado para renderização no app e para exportação de relatórios.


## Dataset, Anotação e Treinamento (Roadmap)
- Coleta/Construção do Dataset
  - Buscar diagramas públicos (licenças permissivas) de arquiteturas (AWS, Azure, GCP, on‑premises) e diagramas genéricos (UML de implantação, C4 Model, etc.).
  - Normalizar formatos (PNG/JPEG) e resoluções.
- Anotação
  - Definir ontologia de componentes (ex.: usuários, ALB/ELB, EC2/Compute, DBs, APIs, Filas, Storages, VPC/Subnets, WAF, CDN).
  - Usar ferramentas de anotação de imagens (ex.: CVAT, Label Studio) com bounding boxes e rótulos.
  - Exportar em formato COCO/YOLO/CSV, conforme o pipeline de treinamento.
- Treinamento do Modelo Supervisionado
  - Selecionar arquitetura (ex.: YOLOv8/RT‑DETR/DETR/Faster R‑CNN) para detecção de objetos.
  - Hiperparâmetros e avaliação (mAP por classe, recall/precision, F1).
  - Exportar pesos e criar endpoint de inferência dedicado (opcional) para complementar/validar a análise multimodal.
- Mapeamento de Vulnerabilidades e Contramedidas
  - Construir base de conhecimento que relacione classes de componentes às ameaças STRIDE e mitigações (fontes: OWASP, CIS Benchmarks, vendor best practices).
  - Integração futura com bancos CVE/NVD para evidências adicionais.


## Boas Práticas de Desenvolvimento
- Logs estruturados no backend (`logging` em `hackaton/backend/main.py`).
- Autenticação via Bearer Token (header `Authorization`).
- Retorno estritamente em JSON para fácil integração com o app Flutter.


## Troubleshooting
- 401 Unauthorized: verifique se `API_AUTH_TOKEN` (backend) e `AUTH_TOKEN` (Flutter) coincidem.
- Erro de rede no emulador Android: use `BASE_URI=http://10.0.2.2:8000`.
- Falha no OpenAI ou Gemini: utilize `GET /health/ai-services` para verificar disponibilidade e chaves (`OPENAI_API_KEY`, `GOOGLE_API_KEY`).
- CORS: caso exponha o backend ao navegador, considere habilitar `fastapi.middleware.cors`.
