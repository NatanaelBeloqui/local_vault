# LocalVault

**Aluno:** Natanael Beloqui de Barros

**Curso:** Desenvolvimento Mobile — SENAC

**Aula:** 13 — Armazenamento Local

Aplicativo Flutter que demonstra as três principais estratégias de persistência local: SharedPreferences, Hive e flutter_secure_storage, aplicando boas práticas de privacidade e os princípios da LGPD.

---

## Funcionalidades

| Tela | Tecnologia | O que faz |
|------|-----------|-----------|
| Token | flutter_secure_storage | Salva, recupera e exclui token de autenticação |
| Perfil | Hive + TypeAdapter | CRUD de perfil do usuário com dados tipados |
| Configurações | SharedPreferences | Persiste tema, idioma e notificações |
| Migração (bônus) | SharedPreferences + Hive | Detecta e migra dados da v1 para v2 |

---

## Por que SharedPreferences para configurações?

SharedPreferences é ideal para armazenar **preferências simples do usuário** — pares chave-valor de tipos primitivos (`bool`, `String`, `int`). Modo escuro, idioma e notificações se enquadram perfeitamente nesse perfil: são dados isolados, pequenos e sem relação entre si. A API é direta e sem necessidade de esquema ou adaptadores, o que torna o código mais simples e fácil de manter.

## Por que Hive para o perfil do usuário?

O perfil do usuário é um **objeto estruturado** com múltiplos campos tipados (`name`, `email`, `registrationDate`, `score`). SharedPreferences não suporta objetos complexos. O Hive resolve isso com TypeAdapters — classes geradas pelo `build_runner` que serializam e desserializam o objeto de forma eficiente. Além disso, o Hive é um banco NoSQL de alto desempenho sem dependências nativas, funcionando muito bem para cenários offline-first.

## Por que flutter_secure_storage para o token?

Tokens de autenticação são dados **sensíveis** — se vazarem, comprometem a conta do usuário. O `flutter_secure_storage` armazena os dados no **Keychain (iOS)** e **Keystore (Android)**, que são áreas do sistema operacional com criptografia de hardware. Armazenar tokens em SharedPreferences seria um risco de segurança grave, pois o arquivo pode ser acessado em dispositivos com root/jailbreak.

---

## Estrutura do Projeto

```
lib/
├── main.dart                          # Inicialização do app, Hive e tema
├── models/
│   ├── user_profile.dart              # HiveObject + @HiveType/@HiveField
│   └── user_profile.g.dart            # TypeAdapter (gerado pelo build_runner)
├── services/
│   ├── settings_service.dart          # SharedPreferences (tema, idioma, notif.)
│   ├── storage_service.dart           # flutter_secure_storage (token)
│   └── migration_service.dart         # Migração v1 → v2 (bônus)
└── screens/
    ├── home_screen.dart               # Token + Migração
    ├── profile_screen.dart            # Hive CRUD
    └── settings_screen.dart           # Configurações
```

---

## Como rodar o projeto

**Pré-requisitos:** Flutter SDK ≥ 3.0, Dart ≥ 3.0

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/local_vault.git
cd local_vault

# 2. Instale as dependências
flutter pub get

# 3. (Opcional) Gere o TypeAdapter via build_runner
#    O arquivo user_profile.g.dart já está incluído no repositório,
#    mas caso queira regenerar:
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Execute o app
flutter run
```

> O arquivo `user_profile.g.dart` já está versionado no repositório para facilitar a execução sem precisar rodar o `build_runner`.

---

## Reflexão — LGPD

> *"Se este app fosse publicado na Play Store, quais dados ele estaria coletando e armazenando? Como você garantiria que o usuário está ciente disso e pode excluir seus dados?"*

O LocalVault armazena localmente:
- **Preferências de uso** (tema, idioma, notificações) — dados anônimos, sem risco à privacidade
- **Perfil do usuário** (nome, e-mail, data de cadastro, pontuação) — dados pessoais conforme LGPD
- **Token de autenticação** — dado sensível de segurança

Para publicação responsável, seriam adotadas as seguintes medidas:

1. **Consentimento explícito:** exibir uma tela de onboarding informando quais dados são coletados e para qual finalidade, antes de qualquer persistência
2. **Minimização de dados:** coletar apenas o que é necessário para a funcionalidade do app (princípio da minimização — Art. 6º, III da LGPD)
3. **Direito ao esquecimento:** o botão "Excluir Perfil" na tela de perfil já implementa isso para os dados do Hive; um fluxo completo incluiria limpar também o SharedPreferences e o token
4. **Transparência:** uma tela de "Política de Privacidade" dentro do app, acessível a qualquer momento nas configurações
5. **Expiração automática:** tokens teriam TTL (tempo de vida) definido, sendo excluídos automaticamente após o período de validade

---

## Dependências

```yaml
shared_preferences: ^2.2.0   # Configurações simples
hive: ^2.2.3                 # Banco NoSQL local
hive_flutter: ^1.1.0         # Integração Hive + Flutter
flutter_secure_storage: ^9.0.0  # Armazenamento seguro (Keychain/Keystore)
provider: ^6.1.0             # Gerenciamento de estado (opcional)

# Dev
hive_generator: ^2.0.1       # Geração de TypeAdapters
build_runner: ^2.4.0         # Runner de geração de código
```

<img width="500" height="944" alt="image" src="https://github.com/user-attachments/assets/393dbfb3-0329-4fb6-9d3d-7b8f64c20eea" />
