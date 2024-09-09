# Bety - Gerenciador de Saúde para Controle Glicêmico

Bety é um aplicativo desenvolvido com Flutter voltado para auxiliar pessoas com diabetes no monitoramento de suas medições glicêmicas e na gestão de pontos de apoio e médicos. O app integra-se com o Firebase para garantir a segurança e a escalabilidade no armazenamento dos dados dos usuários.

## Objetivo

O principal objetivo do Bety é oferecer uma plataforma intuitiva e personalizada para que os usuários possam controlar suas medições de glicose de forma prática e eficiente. Além disso, o aplicativo permite o cadastro de médicos e pontos de apoio no mapa, facilitando o acesso a informações relevantes para a saúde do usuário.

## Funcionalidades

### 1. Registro de Glicemia
- Inserção de medições de glicose por meio de um formulário simples.
- Armazenamento seguro dos dados no Firebase Firestore.
- Exibição das medições em tempo real na tela principal, com opções de editar e deletar.
- Edição dos registros através de uma interface intuitiva e funcional.

### 2. Ponto de Apoio
- Cadastro de locais importantes como hospitais, farmácias e residências diretamente no mapa.
- Conversão de endereços em coordenadas geográficas utilizando as bibliotecas `geocoding` e `geolocator`.
- Exibição da distância entre a localização atual do usuário e os pontos cadastrados no mapa.

### 3. Gerenciamento de Médicos
- Cadastro e gerenciamento de médicos com informações como nome, contato e especialidades.
- Exibição dos médicos cadastrados em uma lista de cartões.
- Filtro por especialidade para facilitar a busca de médicos relevantes.

## Tecnologias Utilizadas

- **Flutter**: Framework principal para o desenvolvimento do app.
- **Firebase Auth**: Gerencia a autenticação dos usuários, garantindo um login seguro.
- **Cloud Firestore**: Banco de dados escalável em tempo real para armazenar as medições de glicose, pontos de apoio e informações dos médicos.
- **Firebase Storage**: Armazenamento de documentos e imagens médicas.
- **Google Maps Flutter Plugin**: Renderização de mapas para a funcionalidade de pontos de apoio.
- **Geocoding e Geolocator**: Bibliotecas para conversão de endereços em coordenadas geográficas.

## Conversão de Dados

O aplicativo utiliza JSON para a conversão de dados ao interagir com o Firebase. As entidades, como `Glicemia`, possuem métodos de conversão para transformar os documentos do Firestore em objetos de domínio, facilitando a manipulação dos dados.

## Screenshots

- **Registro de Glicemia**
  ![Registro de Glicemia](caminho_para_imagem)

- **Gerenciamento de Médicos**
  ![Gerenciamento de Médicos](caminho_para_imagem)

- **Ponto de Apoio**
  ![Ponto de Apoio](caminho_para_imagem)

