const Components = {}
export const registerGlobalComponents = (app) => {
    for (let item in Components) {
        app.component(item, Components[item]);
    }
};