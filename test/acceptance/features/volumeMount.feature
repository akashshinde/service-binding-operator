Feature: Bind an application to a service using volume mount

    As a user of Service Binding Operator
    I want to bind applications to services it depends on
    using volume mount

    Background:
        Given Namespace [TEST_NAMESPACE] is used
        * Service Binding Operator is running

    Scenario: Binding is injected as file into application pod at given location
        Given OLM Operator "backend" is running
        * Generic test application "generic-app-a-d-u" is running with binding root as "/var/data"
        * The Custom Resource is present
            """
            apiVersion: "stable.example.com/v1"
            kind: Backend
            metadata:
                name: backend-demo
                annotations:
                    "service.binding/host": "path={.spec.host}"
                    "service.binding/port": "path={.spec.port}"
            spec:
                host: example.common
                port: 8080
            """
        When Service Binding is applied
            """
            apiVersion: operators.coreos.com/v1alpha1
            kind: ServiceBinding
            metadata:
                name: binding-backend
            spec:
                bindAsFiles: true
                services:
                -   group: stable.example.com
                    version: v1
                    kind: Backend
                    name: backend-demo
                    id: bk

                customEnvVar:
                  - name: MYHOST
                    value: '{{ .bk.spec.host }}'

                application:
                    name: generic-app-a-d-u
                    group: apps
                    version: v1
                    resource: deployments
            """
        Then jq ".status.conditions[] | select(.type=="CollectionReady").status" of Service Binding "binding-backend" should be changed to "True"
        And jq ".status.conditions[] | select(.type=="InjectionReady").status" of Service Binding "binding-backend" should be changed to "True"
        And The env var "BACKEND_HOST" is not available to the application
        And The env var "BACKEND_PORT" is not available to the application
        And Content of file "/var/data/binding-backend/BACKEND_HOST" in application pod is
            """
            example.common
            """
        And Content of file "/var/data/binding-backend/BACKEND_PORT" in application pod is
            """
            8080
            """
        And Content of file "/var/data/binding-backend/MYHOST" in application pod is
            """
            example.common
            """

    Scenario: Binding is injected as file into application pod at default location
        Given OLM Operator "backend" is running
        * Generic test application "generic-app-a-d-u" is running
        * The Custom Resource is present
            """
            apiVersion: "stable.example.com/v1"
            kind: Backend
            metadata:
                name: backend-demo
                annotations:
                    "service.binding/host": "path={.spec.host}"
                    "service.binding/port": "path={.spec.port}"
            spec:
                host: example.common
                port: 8080
            """
        When Service Binding is applied
            """
            apiVersion: operators.coreos.com/v1alpha1
            kind: ServiceBinding
            metadata:
                name: binding-backend
            spec:
                bindAsFiles: true
                services:
                -   group: stable.example.com
                    version: v1
                    kind: Backend
                    name: backend-demo

                application:
                    name: generic-app-a-d-u
                    group: apps
                    version: v1
                    resource: deployments
            """
        Then jq ".status.conditions[] | select(.type=="CollectionReady").status" of Service Binding "binding-backend" should be changed to "True"
        And jq ".status.conditions[] | select(.type=="InjectionReady").status" of Service Binding "binding-backend" should be changed to "True"
        And The env var "BACKEND_HOST" is not available to the application
        And The env var "BACKEND_PORT" is not available to the application
        And Content of file "/bindings/binding-backend/BACKEND_HOST" in application pod is
            """
            example.common
            """
        And Content of file "/bindings/binding-backend/BACKEND_PORT" in application pod is
            """
            8080
            """

    Scenario: Binding is injected as file into application pod at overriden location
        Given OLM Operator "backend" is running
        * Generic test application "generic-app-a-d-u" is running
        * The Custom Resource is present
            """
            apiVersion: "stable.example.com/v1"
            kind: Backend
            metadata:
                name: backend-demo
                annotations:
                    "service.binding/host": "path={.spec.host}"
                    "service.binding/port": "path={.spec.port}"
            spec:
                host: example.common
                port: 8080
            """
        When Service Binding is applied
            """
            apiVersion: operators.coreos.com/v1alpha1
            kind: ServiceBinding
            metadata:
                name: binding-backend
            spec:
                mountPath: "/foo/bar"
                bindAsFiles: true
                services:
                -   group: stable.example.com
                    version: v1
                    kind: Backend
                    name: backend-demo

                application:
                    name: generic-app-a-d-u
                    group: apps
                    version: v1
                    resource: deployments
            """
        Then jq ".status.conditions[] | select(.type=="CollectionReady").status" of Service Binding "binding-backend" should be changed to "True"
        And jq ".status.conditions[] | select(.type=="InjectionReady").status" of Service Binding "binding-backend" should be changed to "True"
        And The env var "BACKEND_HOST" is not available to the application
        And The env var "BACKEND_PORT" is not available to the application
        And Content of file "/foo/bar/BACKEND_HOST" in application pod is
            """
            example.common
            """
        And Content of file "/foo/bar/BACKEND_PORT" in application pod is
            """
            8080
            """
