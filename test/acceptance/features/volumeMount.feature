Feature: Bindings get injected as files in application

    As a user of Service Binding Operator
    I want to bind applications to services it depends on
    using files

    Background:
        Given Namespace [TEST_NAMESPACE] is used
        * Service Binding Operator is running

    Scenario: Binding is injected as files at the location of SERVICE_BINDING_ROOT env var
        Given OLM Operator "backend" is running
        * Generic test application "generic-app-a-d-u-1" is running with binding root as "/var/data"
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
                name: binding-backend-vm-01
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
                    name: generic-app-a-d-u-1
                    group: apps
                    version: v1
                    resource: deployments
            """
        Then jq ".status.conditions[] | select(.type=="CollectionReady").status" of Service Binding "binding-backend-vm-01" should be changed to "True"
        And jq ".status.conditions[] | select(.type=="InjectionReady").status" of Service Binding "binding-backend-vm-01" should be changed to "True"
        And The env var "BACKEND_HOST" is not available to the application
        And The env var "BACKEND_PORT" is not available to the application
        And The env var "MYHOST" is not available to the application
        And Content of file "/var/data/binding-backend-vm-01/BACKEND_HOST" in application pod is
            """
            example.common
            """
        And Content of file "/var/data/binding-backend-vm-01/BACKEND_PORT" in application pod is
            """
            8080
            """
        And Content of file "/var/data/binding-backend-vm-01/MYHOST" in application pod is
            """
            example.common
            """

    Scenario: Binding is injected as file into application at default location
        Given OLM Operator "backend" is running
        * Generic test application "generic-app-a-d-u-2" is running
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
                name: binding-backend-vm-02
            spec:
                bindAsFiles: true
                services:
                -   group: stable.example.com
                    version: v1
                    kind: Backend
                    name: backend-demo

                application:
                    name: generic-app-a-d-u-2
                    group: apps
                    version: v1
                    resource: deployments
            """
        Then jq ".status.conditions[] | select(.type=="CollectionReady").status" of Service Binding "binding-backend-vm-02" should be changed to "True"
        And jq ".status.conditions[] | select(.type=="InjectionReady").status" of Service Binding "binding-backend-vm-02" should be changed to "True"
        And The env var "BACKEND_HOST" is not available to the application
        And The env var "BACKEND_PORT" is not available to the application
        And Content of file "/bindings/binding-backend-vm-02/BACKEND_HOST" in application pod is
            """
            example.common
            """
        And Content of file "/bindings/binding-backend-vm-02/BACKEND_PORT" in application pod is
            """
            8080
            """

    Scenario: Binding is injected as file into application at the location specified through mountPath
        Given OLM Operator "backend" is running
        * Generic test application "generic-app-a-d-u-2" is running without SERVICE_BINDING_ROOT
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
                name: binding-backend-vm-03
            spec:
                mountPath: "/foo/bar"
                bindAsFiles: true
                services:
                -   group: stable.example.com
                    version: v1
                    kind: Backend
                    name: backend-demo

                application:
                    name: generic-app-a-d-u-2
                    group: apps
                    version: v1
                    resource: deployments
            """
        Then jq ".status.conditions[] | select(.type=="CollectionReady").status" of Service Binding "binding-backend-vm-03" should be changed to "True"
        And jq ".status.conditions[] | select(.type=="InjectionReady").status" of Service Binding "binding-backend-vm-03" should be changed to "True"
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

    Scenario: Binding is injected as files at the location of SERVICE_BINDING_ROOT env var even with mountPath
        Given OLM Operator "backend" is running
        * Generic test application "generic-app-a-d-u-3" is running with binding root as "/var/data"
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
                name: binding-backend-vm-04
            spec:
                mountPath: "/foo/bar"
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
                    name: generic-app-a-d-u-3
                    group: apps
                    version: v1
                    resource: deployments
            """
        Then jq ".status.conditions[] | select(.type=="CollectionReady").status" of Service Binding "binding-backend-vm-04" should be changed to "True"
        And jq ".status.conditions[] | select(.type=="InjectionReady").status" of Service Binding "binding-backend-vm-04" should be changed to "True"
        And The env var "BACKEND_HOST" is not available to the application
        And The env var "BACKEND_PORT" is not available to the application
        And Content of file "/var/data/binding-backend-vm-04/BACKEND_HOST" in application pod is
            """
            example.common
            """
        And Content of file "/var/data/binding-backend-vm-04/BACKEND_PORT" in application pod is
            """
            8080
            """
        And Content of file "/var/data/binding-backend-vm-04/MYHOST" in application pod is
            """
            example.common
            """

    Scenario: Binding is injected as file into application at the location specified through mountPath with empty prefix
        Given OLM Operator "backend" is running
        * Generic test application "generic-app-a-d-u-2" is running without SERVICE_BINDING_ROOT
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
                name: binding-backend-vm-03
            spec:
                mountPath: "/foo/bar"
                bindAsFiles: true
                services:
                -   group: stable.example.com
                    version: v1
                    kind: Backend
                    name: backend-demo
                    envVarPrefix: ""

                application:
                    name: generic-app-a-d-u-2
                    group: apps
                    version: v1
                    resource: deployments
            """
        Then jq ".status.conditions[] | select(.type=="CollectionReady").status" of Service Binding "binding-backend-vm-03" should be changed to "True"
        And jq ".status.conditions[] | select(.type=="InjectionReady").status" of Service Binding "binding-backend-vm-03" should be changed to "True"
        And The env var "HOST" is not available to the application
        And The env var "PORT" is not available to the application
        And Content of file "/foo/bar/HOST" in application pod is
            """
            example.common
            """
        And Content of file "/foo/bar/PORT" in application pod is
            """
            8080
            """
