# Controle de Materiais — Rede de Distribuição Elétrica

App para controlar materiais e movimentações entre obras (código **B**) de rede
de distribuição elétrica de até 34 kV. Feito para uso em campo, no celular,
como PWA instalável, mas funciona igual no PC.

## Stack

React + TypeScript + Vite + Tailwind CSS + Supabase (PostgreSQL + Auth) + PWA.

## 1. Criar o projeto no Supabase

1. Crie uma conta e um projeto em https://supabase.com.
2. **SQL Editor → New query** → cole todo o conteúdo de `supabase/schema.sql` → Run.
3. Em **Settings → API Keys** (ou no botão **Connect** da página principal do
   projeto), copie a **Project URL** e a chave **anon / public**.
4. Em **Authentication → Providers**, deixe **Email** habilitado.
5. Crie um usuário em **Authentication → Users → Add user** (e-mail + senha).
6. Em **Table Editor → profiles**, ache esse usuário e mude `role` para
   `admin` (todo usuário novo nasce como `encarregado`; sem um admin,
   ninguém cadastra Obra/Material pela interface).
7. Em **Authentication → URL Configuration**, adicione a URL onde o app vai
   rodar em **Redirect URLs** (necessário para "Esqueci minha senha").

> Se você já tinha rodado uma versão anterior do `schema.sql` (sem perfis),
> rode também `supabase/002_perfis_e_permissoes.sql` — ele só completa o
> que falta, sem apagar nada.

## 2. Rodar / publicar

### Com PC
```bash
cp .env.example .env
# edite .env com a URL e a anon key do seu projeto Supabase
npm install
npm run dev
```
Para publicar: `npm run build` gera a pasta `dist/` — suba em qualquer
hospedagem estática (Netlify, Vercel, Cloudflare Pages), configurando lá as
mesmas duas variáveis de ambiente.

### Sem PC, pelo Android (Termux)
Veja o arquivo `build.sh` — ele instala as dependências, cria o `.env`
perguntando os dados do Supabase, e gera o build em um único comando:
```bash
bash build.sh
```
Depois, para publicar: `netlify deploy --prod --dir dist` (ou arraste a
pasta `dist` em https://app.netlify.com/drop).

### Via GitHub + Netlify (build na nuvem, sem terminal)
1. Crie um repositório no GitHub e suba os arquivos pela página
   **Add file → Upload files** (dá pra selecionar vários arquivos de uma vez
   por pasta).
2. Na Netlify: **Add new site → Import an existing project → GitHub** →
   selecione o repositório.
3. **Build command**: `npm run build` · **Publish directory**: `dist`
4. Em **Environment variables**, adicione `VITE_SUPABASE_URL` e
   `VITE_SUPABASE_ANON_KEY`.
5. Deploy — a Netlify builda sozinha a cada atualização enviada ao GitHub.

O arquivo `public/_redirects` já está incluído — ele é necessário para as
rotas internas do app (como `/obras/:id`) funcionarem quando publicado.

## Login e permissões

Tela de e-mail/senha com "Esqueci minha senha". Não há cadastro público —
usuários são criados pelo administrador no painel do Supabase. Cada
movimentação fica vinculada ao usuário logado.

Papéis (tabela `profiles`):
- **admin** — cadastra e edita Obras e Materiais (inclusive marcar um
  material como inativo), além de tudo que o encarregado faz.
- **encarregado** — vê tudo, faz transferências e entradas de material; não
  vê os botões de cadastro/edição (e o banco bloqueia via RLS mesmo que
  tente pela API direto).

A troca de papel é sempre manual, na tabela `profiles` do Supabase.

## Editar Obras e Materiais

- Na página de uma obra (`/obras/:id`), o lápis ao lado do status abre a
  edição — só aparece para admin.
- Na lista de Materiais, o lápis em cada item edita e permite marcar como
  **inativo** (some das opções de entrada nova, mas continua no histórico).

## Entrada de material

Na tela **Transferir**, tem um alternador no topo: **"Entre obras"** (fluxo
de sempre) ou **"Entrada nova"** (dá entrada de material comprado/recebido
direto numa obra, sem origem). Usa a função `registrar_entrada` do banco.

## Backup

Aba **Backup**: exporta um `.json` com tudo (obras, materiais, estoques,
histórico) e permite restaurar — útil pra popular um projeto Supabase novo
ou recuperar dados. O histórico nunca é sobrescrito, só completado.

## Estrutura

```
src/
  components/   Layout (sidebar + navegação inferior), AuthGate, busca de
                obra, badges, item de histórico
  contexts/     AuthContext (sessão e papel do Supabase Auth)
  lib/          cliente Supabase
  pages/        Login, NovaSenha, Dashboard, Obras, ObraDetalhe, Materiais,
                Transferencia, Historico, Backup
  types/        tipos TypeScript espelhando o schema do banco
supabase/
  schema.sql                     tudo, para projeto novo
  002_perfis_e_permissoes.sql    só o incremento, para quem já tinha rodado uma versão anterior
build.sh        script para gerar o build via Termux (Android), sem PC
```

## Regras já garantidas pelo banco (não só pela interface)

- **Estoque nunca fica negativo**: `transferir_material` trava a linha de
  estoque da origem (`for update`) e verifica o saldo na mesma transação.
- **Atomicidade**: débito, crédito e histórico acontecem na mesma transação
  — se algo falhar, tudo é revertido.
- **Histórico imutável**: não há policy de update/delete em
  `movimentacoes`; só se grava por `transferir_material`/`registrar_entrada`.

## O que falta (próximas etapas)

- Ícones 192×192 e 512×512 para o PWA ficar com ícone próprio.
- Cadastro público de usuários (hoje só via painel do Supabase, de propósito).
- Papéis mais granulares, se precisar (hoje é só admin/encarregado).
