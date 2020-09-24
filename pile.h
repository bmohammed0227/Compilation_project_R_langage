typedef struct Element Element;
struct Element{
    char* valeur;
    Element* suivant;
};

typedef struct Pile Pile;
struct Pile{
    Element* enTete;
};

Pile* initialiser(){
    Pile* pile = malloc(sizeof(pile));
    Element* enTete = malloc(sizeof(enTete));
    if(pile == NULL || enTete == NULL){
        exit(EXIT_FAILURE);
    }
    enTete->valeur = "";
    enTete->suivant = NULL;
    pile->enTete = enTete;
    return pile;
}

void empiler(Pile* pile, char* valeur){
    Element* nouveau = malloc(sizeof(*nouveau));
    if(pile == NULL || nouveau == NULL){
        exit(EXIT_FAILURE);
    }
    nouveau->valeur = valeur;
    nouveau->suivant = pile->enTete;
    pile->enTete = nouveau;
};

char* depiler(Pile* pile){
    if(pile == NULL){
        exit(EXIT_FAILURE);
    }
    char* valeur = "";
    if(pile->enTete != NULL){
        valeur = (pile->enTete)->valeur;
        pile->enTete = (pile->enTete)->suivant;
    }
    return valeur;
}

void afficherPile(Pile *pile){
    if(pile == NULL){
        exit(EXIT_FAILURE);
    }
    Element* actuel = pile->enTete;
    while(actuel != NULL){
        printf("%s\n", actuel->valeur);
        actuel = actuel->suivant;
    }
}
