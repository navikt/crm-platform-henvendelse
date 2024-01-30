({
    redirectToHenvendelse: function (component) {
        const henvRef = this.getReference(component);
        this.getHenvIdAndRedirect(component, henvRef);
    },

    getReference: function (component) {
        const state = component.get('v.pageReference').state;
        const henvId = state.c__henvendelseId;
        return henvId;
    },

    getHenvIdAndRedirect: function (component, henvRef) {
        //Call controller
        let action = component.get('c.getHenvRecordId');
        action.setParams({ apiReference: henvRef });

        action.setCallback(this, (response) => {
            var state = response.getState();
            if (state === 'SUCCESS') {
                let henvId = response.getReturnValue();
                this.navigateToHenvendelse(component, henvId);
                this.closeWorkspaceTab(component);
            } else {
                this.handleError(
                    component,
                    'Det oppsto en feil ved henting av dialogen \n' + response.getError()[0].message
                );
            }

            component.set('v.loading', false);
        });

        $A.enqueueAction(action);
    },

    handleError: function (component, errorMsg) {
        component.find('notifLib').showNotice({
            variant: 'error',
            header: 'En uventet feil oppsto!',
            message: errorMsg
        });
    },

    closeWorkspaceTab: function (component) {
        let workspaceAPI = component.find('workspace');
        workspaceAPI
            .getEnclosingTabId()
            .then((tabId) => {
                workspaceAPI
                    .closeTab({ tabId: tabId })
                    .then(() => {
                        //Success
                    })
                    .catch((error) => {
                        console.log(JSON.stringify(error, null, 2));
                    });
            })
            .catch((error) => {
                console.log(JSON.stringify(error, null, 2));
            });
    },

    navigateToHenvendelse: function (component, henvId) {
        let navService = component.find('navService');

        let navReference = {
            type: 'standard__recordPage',
            attributes: { recordId: henvId, actionName: 'view' }
        };
        navService.navigate(navReference);
    }
});
