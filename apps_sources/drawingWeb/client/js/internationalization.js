var lang = 'en'
var langs = {
    en : {
        connect:"Click to connect",
        brushSize: "Brush size",
        rotationSpeed: "Rotation speed",
        timeLapsBetween2Rot: "Time between two image rotations",
        clearWhiteboard: "Clear the whiteboard",
        saveDrawing: "Click to save the sphere.colors file",
        imgProcessing: "Activate/Disable the image processing, could be longer if activated but the rendering is better",
        connected: "Connected",
        disconnected: "Disconnected",
        reconnecting: "Reconnection"
    },
    fr : {
        connect:"Clique pour te connecter",
        brushSize: "Taille du pinceau",
        rotationSpeed: "Vitesse de rotattion",
        rotImg: "Temps entre deux rotaion de l'image",
        clearWhiteboard: "Nettoyer la zone de dessin",
        saveDrawing: "Clique pour sauvegarder le fichier sphere.colors",
        imgProcessing: "Activer/Désactiver le traitement de l'image. Le rendu est meilleur sur le globe si activé mais BEAUCOUP plus long",
        connected: "Connecté",
        disconnected: "Déconnecté",
        reconnecting: "Reconnection"
    }
};

var id2Lang = {
    connect:"connect",
    lBrushSize:"brushSize",
    clearWhiteboard:"clearWhiteboard",
    saveSphereFile:"saveDrawing",
    lRotateImg:"rotImg",
    lRotationSpeed:"rotationSpeed",
    lImgProcessing:"imgProcessing"
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
