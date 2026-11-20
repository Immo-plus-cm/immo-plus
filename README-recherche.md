# Immo+ — recherche de logement

La page de recherche dédiée est `recherche.html`. Le site Immo+ existant est déjà publié avec GitHub Pages ; cette page est ajoutée au même dépôt et sera publiée à l’URL :

`https://immo-plus-cm.github.io/immo-plus/recherche.html`

## Activer les demandes et la messagerie

Le projet Supabase existant est utilisé. Pour créer les tables et activer les règles de confidentialité :

1. Ouvrez **Supabase → SQL Editor** pour le projet Immo+.
2. Exécutez le contenu de [`supabase/recherche-logement.sql`](supabase/recherche-logement.sql).
3. Vérifiez que le compte administrateur possède `profiles.type_compte = 'admin'`.
4. Dans Supabase Auth, configurez l’URL de redirection vers `https://immo-plus-cm.github.io/immo-plus/` et les URL autorisées du site, si la connexion l’exige.

Après cette configuration, un utilisateur connecté peut déposer une recherche. L’administrateur la voit dans son espace, peut l’accepter ou la refuser, et la messagerie s’ouvre uniquement pour une demande acceptée. Les politiques RLS limitent les demandes aux personnes concernées et aux administrateurs.

La publication GitHub Pages peut prendre quelques minutes après le commit. Les clés intégrées à la page sont des clés publiques Supabase ; ne jamais y placer une clé `service_role`.
