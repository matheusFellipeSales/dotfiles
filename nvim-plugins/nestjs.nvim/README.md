# NestJS Neovim Plugin

Plugin para Neovim que facilita a criação de Use Cases e testes para projetos NestJS.

## Funcionalidades

- **Criação de Use Cases**: Gera automaticamente arquivos de Use Case seguindo padrões do NestJS
- **Geração de Testes**: Cria arquivos `.spec.ts` correspondentes
- **Integração com Neo-tree**: Funciona perfeitamente com o gerenciador de arquivos Neo-tree

## Comandos e Atalhos

### Comando

- `:Case` - Abre prompt para criar um novo Use Case

### Atalhos

- `<leader>ts` - Criar arquivo de teste `.spec.ts` para o arquivo atual
- `U` - Criar Use Case + teste (funciona em qualquer lugar, especialmente no Neo-tree)

## Uso

1. No Neo-tree, navegue até a pasta onde deseja criar o Use Case
2. Pressione `U`
3. Digite o nome do Use Case (ex: "Create User")
4. O plugin criará:
   - `create-user-use-case.ts` (Use Case)
   - `create-user-use-case.spec.ts` (Teste)

## Estrutura dos Arquivos Gerados

### Use Case

```typescript
import { Injectable } from "@nestjs/common";

type Input = {};

type Output = {};

@Injectable()
export class CreateUserUseCase {
  async execute(input: Input): Promise<Output> {}
}
```

### Teste

```typescript
import { Test, TestingModule } from "@nestjs/testing";
import { CreateUserUseCase } from "./create-user-use-case";

describe("CreateUserUseCase", () => {
  let useCase: CreateUserUseCase;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [CreateUserUseCase],
    }).compile();

    useCase = module.get<CreateUserUseCase>(CreateUserUseCase);
  });

  it("should be defined", () => {
    expect(useCase).toBeDefined();
  });
});
```
