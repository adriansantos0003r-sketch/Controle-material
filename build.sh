#!/data/data/com.termux/files/usr/bash
set -e

if [ ! -f .env ]; then
  echo "Vamos criar o arquivo .env (dados do seu projeto Supabase)."
  read -p "Cole aqui a Project URL do Supabase: " SUPABASE_URL
  read -p "Cole aqui a chave anon/public: " SUPABASE_KEY
  printf "VITE_SUPABASE_URL=%s\nVITE_SUPABASE_ANON_KEY=%s\n" "$SUPABASE_URL" "$SUPABASE_KEY" > .env
  echo ".env criado."
  echo ""
fi

echo "Instalando dependências (pode demorar alguns minutos na primeira vez)..."
npm install

echo ""
echo "Gerando os arquivos do site..."
npm run build

echo ""
echo "✅ Tudo pronto! A pasta 'dist' está pronta pra publicar."
echo ""
echo "Primeira vez? Rode:"
echo "  npm install -g netlify-cli && netlify login"
echo ""
echo "Pra publicar (sempre que quiser atualizar o site):"
echo "  netlify deploy --prod --dir dist"
