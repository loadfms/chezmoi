## Passo a passo: clonar e aplicar seu repo chezmoi

1. Instalar o chezmoi
```sh
sudo pacman -S chezmoi
```

2. Inicializar com o seu repositório

```sh
chezmoi init --apply loadfms/chezmoi
```

Esse comando:
- Clona o repo https://github.com/loadfms/chezmoi
- Aplica todos os arquivos no seu $HOME

## Para testar antes de aplicar (opcional)

Se quiser ver o que será feito sem aplicar de imediato:

```sh
chezmoi init loadfms/chezmoi
chezmoi diff         # mostra diferenças
chezmoi apply        # aplica quando estiver pronto
```

## Para selecionar o tema:
```sh
change-theme gruvbox
```
