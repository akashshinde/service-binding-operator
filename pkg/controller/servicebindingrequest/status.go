package servicebindingrequest

import (
	"github.com/redhat-developer/service-binding-operator/pkg/apis/apps/v1alpha1"
)

func (r *Reconciler) setBindingSuccessStatus(sbr *v1alpha1.ServiceBindingRequest) {
	sbr.Status.BindingStatus = v1alpha1.BindingSuccess
}

func (r *Reconciler) setBindingInProgressStatus(sbr *v1alpha1.ServiceBindingRequest) {
	sbr.Status.BindingStatus = v1alpha1.BindingInProgress
}

func (r *Reconciler) setBindingFailStatus(sbr *v1alpha1.ServiceBindingRequest) {
	sbr.Status.BindingStatus = v1alpha1.BindingFail
}