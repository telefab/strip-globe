var lang = 'en'
var langs = {
    en : {
        connect:"Click to connect",
        brushSize: "Brush size",
        rotationSpeed: "Globe rotation",
        rotImg: "Image rotation",
        clearWhiteboard: "Clear",
        saveDrawing: "Save",
        imgProcessing: "Process the image",
        connected: "Connected",
        disconnected: "Disconnected",
        reconnecting: "Reconnection",
        imgLoad: "Load",
        color: "Color"
    },
    fr : {
        connect:"Clique pour te connecter",
        brushSize: "Taille du pinceau",
        rotationSpeed: "Rotation du globe",
        rotImg: "Rotation de l'image",
        clearWhiteboard: "Nettoyer",
        saveDrawing: "Sauvegarder",
        imgProcessing: "Traiter l'image",
        connected: "Connecté",
        disconnected: "Déconnecté",
        reconnecting: "Reconnection",
        imgLoad: "Charger le dessin",
        color: "Couleur"
    }
};

var id2Lang = {
    connect:"connect",
    lBrushSize:"brushSize",
    clearWhiteboard:"clearWhiteboard",
    saveSphereFile:"saveDrawing",
    lRotateImg:"rotImg",
    lRotationSpeed:"rotationSpeed",
    lImgProcessing:"imgProcessing",
    lImgLoad:"imgLoad",
    lColor:"color"
}

function internationalize(aLang){
    if(! ['en','fr'].indexOf(aLang))
        lang = 'en';
    else
        lang = aLang;
    for(var tag in id2Lang){
        $("#" + tag).text(langs[lang][id2Lang[tag]]);
    }

}
