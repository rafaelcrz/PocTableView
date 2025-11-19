# PocTableView - Chat App iOS

Um aplicativo iOS simples de chat desenvolvido com UIKit e Swift.

## 📱 Descrição

Este é um aplicativo de demonstração que simula uma interface de chat. O app permite que o usuário envie mensagens e recebe respostas automáticas simuladas.

## ✨ Características

- **Interface totalmente programática**: Sem uso de Storyboards para a interface principal
- **UITableView**: Lista de mensagens com células customizadas
- **Mensagens estilizadas**: Balões de mensagem diferentes para usuário (azul, direita) e bot (cinza, esquerda)
- **Resposta automática**: Simula respostas do bot após o envio de mensagens
- **Scroll automático**: A lista rola automaticamente para mostrar as mensagens mais recentes
- **Gerenciamento de teclado**: A interface se ajusta quando o teclado aparece/desaparece
- **Envio por Enter**: Possibilidade de enviar mensagens pressionando Return no teclado

## 🏗️ Estrutura do Projeto

```
PocTableView/
├── AppDelegate.swift              # Configuração do app
├── SceneDelegate.swift             # Gerenciamento de cenas
├── ChatViewController.swift        # ViewController principal com toda a lógica
├── Message.swift                   # Modelo de dados para mensagens
├── MessageTableViewCell.swift      # Célula customizada para exibir mensagens
├── Info.plist                      # Configurações do app
├── LaunchScreen.storyboard         # Tela de abertura
└── README.md                       # Este arquivo
```

## 🎯 Funcionalidades Implementadas

### Interface
- ✅ UITableView para listar mensagens
- ✅ UITextField para entrada de texto
- ✅ UIButton para enviar mensagens
- ✅ Campo de entrada e botão fixos na parte inferior

### Comportamento
- ✅ Envio de mensagens ao clicar no botão
- ✅ Envio de mensagens ao pressionar Return/Enter
- ✅ Resposta automática simulada após 1 segundo
- ✅ Mensagens ordenadas do mais antigo (topo) para o mais recente (embaixo)
- ✅ Scroll automático para as mensagens mais recentes
- ✅ Ajuste automático da interface quando o teclado aparece
- ✅ Limpeza do campo de texto após envio

### Design
- ✅ Balões de mensagem estilizados
- ✅ Cores diferentes para mensagens do usuário (azul) e bot (cinza)
- ✅ Alinhamento à direita para mensagens do usuário
- ✅ Alinhamento à esquerda para mensagens do bot
- ✅ Layout responsivo usando AutoLayout

## 🚀 Como Executar

1. Abra o projeto no Xcode
2. Selecione um simulador iOS ou dispositivo físico
3. Pressione `Cmd + R` para compilar e executar

## 📋 Requisitos

- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

## 💡 Conceitos Demonstrados

- UIKit programático (sem Storyboards)
- UITableView com Delegate e DataSource
- Células customizadas (UITableViewCell)
- AutoLayout via código
- TextField Delegate
- Notificações do sistema (teclado)
- Animations
- Gestures (UITapGestureRecognizer)

## 🎨 Melhorias Futuras Possíveis

- Persistência de mensagens com Core Data ou UserDefaults
- Timestamps nas mensagens
- Avatares para usuário e bot
- Indicador de digitação
- Sons de notificação
- Compartilhamento de mensagens
- Temas claro/escuro customizados
- Suporte para emojis e imagens

