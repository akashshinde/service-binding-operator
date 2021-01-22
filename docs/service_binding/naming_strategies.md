## What is naming strategy
Naming strategy defines a way to prepare custom environment variables through
ServiceBinding request.

1. We have a nodejs application which connects to database.
2. Application mostly requires host address and exposed port information.
3. Application access this information through environment variable.


###How ?
Following fields are part of `ServiceBinding` request.
- Application
```yaml
  application:
    name: nodejs-app
    group: apps
    version: v1
    resource: deployments
```

- Backend/Database Service
```yaml
namingStrategy: 'POSTGRES_{{ .service.kind | upper }}_{{ .name | upper }}_ENV'
services:
  - group: postgresql.baiju.dev
    version: v1alpha1
    kind: Database
    name: db-demo
```

Considering following are the fields exposed by above service to use for binding
1. host
2. port

We have applied `POSTGRES_{{ .service.kind | upper }}_{{ .name | upper }}_ENV` naming strategy
1. `.name` refers to the binding name specified in the crd annotation or descriptor.
2. `.service` refer to the services in the `ServiceBinding` request.
3. `upper` is the string function used to postprocess the string while compiling the template string.
4. `POSTGRES` is the prefix used.
5. `ENV` is the suffix used.

Following would be list of environment variables prepared by above `ServiceBinding`

```yaml
POSTGRES_DATABASE_HOST_ENV: example.com
POSTGRES_DATABASE_PORT_ENV: 8080
```

We can define how that key should be prepared defining string template in `namingStrategy`

### Naming Strategies
Naming strategies defines how environment variable key should be prepared.

There are few naming strategies predefine.
1. `none` - `{{ .name }}` - When this is applied, we get environment variables in following form
```yaml
host: example.com
port: 8080
```


2. `default` - `{{ .name | upper }}` This is by default set when no `namingStrategy` is defined in the global scope as well as in the local scope service field.

```yaml
HOST: example.com
PORT: 8080
```

3. `bindAsFiles` - `{{ .name }}` This naming strategy is by default set when `bindAsFiles` set true in `ServiceBinding` request.

```yaml
host: example.com
port: 8080
```

#### Predefined string post processing functions
1. `upper` - Capatalize all letters
2. `lower` - Lowercase all letters
3. `title` - Title case all letters.
