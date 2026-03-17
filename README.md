# MaxStack

**MaxStack** est un gestionnaire de scripts et d'outils automatisé pour 3ds Max. Il intègre son propre menu personnalisé et un système de mise à jour automatique intelligent lié à GitHub.

## ✨ Fonctionnalités
* **Installation en 1 clic :** Un simple glisser-déposer suffit pour tout installer.
* **Menu Automatique :** Intégration transparente dans l'interface de 3ds Max sans configuration manuelle.
* **Auto-Update :** Vérification silencieuse des mises à jour au démarrage de 3ds Max. Si une nouvelle version est disponible sur GitHub, elle vous est proposée et s'installe toute seule.
* **Gestion centralisée :** Tous vos scripts vitaux (Mirror, MoveHalf, PasteAsset, etc.) accessibles rapidement.

## 💻 Compatibilité
* **3ds Max 2025 et 2026+** (Utilise le nouveau système de menu `ICuiMenuMgr`).
* *Note : L'installation des macros fonctionnera sur les anciennes versions, mais le menu nécessitera un redémarrage ou une configuration manuelle.*

---

## 🚀 Installation

L'installation de MaxStack a été conçue pour être la plus simple possible :

1. Allez sur la page des [Releases GitHub](https://github.com/full-blood/maxstack/releases/latest).
2. Dans la section **Assets** tout en bas de la dernière version, téléchargez le fichier **`MaxStack.mzp`**.
3. Ouvrez 3ds Max.
4. **Glissez et déposez** simplement le fichier `MaxStack.mzp` depuis votre dossier de téléchargement directement dans la fenêtre (viewport) de 3ds Max.
   * *Alternative : Dans 3ds Max, allez dans le menu `Scripting` > `Run Script...` et sélectionnez le fichier `.mzp`.*
5. Une fenêtre de confirmation apparaîtra pour vous indiquer que l'installation a réussi. Le menu MaxStack apparaîtra instantanément en haut de votre écran !

---

## 🔄 Mise à jour

Vous n'avez plus besoin de télécharger manuellement les nouvelles versions ! 

* **Au démarrage :** MaxStack vérifie silencieusement s'il existe une nouvelle version. Si c'est le cas, une fenêtre vous proposera de la télécharger et de l'installer automatiquement.
* **Manuellement :** À tout moment, vous pouvez aller dans le menu **MaxStack > À propos de MaxStack**. L'outil vérifiera votre version et vous proposera de faire la mise à jour si nécessaire.

---

## 🛠️ Désinstallation (Dépannage)

Si vous souhaitez retirer MaxStack de votre système, supprimez les fichiers suivants :
1. Dans le dossier `usermacros` de 3ds Max, supprimez tous les fichiers commençant par `MaxStack`.
2. Dans le dossier `startup` (`...\scripts\startup\`), supprimez `MaxStack_loader.ms`.
3. Dans le dossier `User Settings`, supprimez `MaxStack.mnx`.

## 👨‍💻 Pour les développeurs (Build)

Pour compiler une nouvelle version du `.mzp` :
1. Clonez ce dépôt.
2. Lancez le fichier `make_mzp.cmd`.
3. Le script incrémentera automatiquement la version, packagera les fichiers, et proposera de faire le `git push`.
4. Créez une nouvelle **Release** sur GitHub en utilisant le Tag correspondant à la version, et attachez-y le nouveau `MaxStack.mzp`.