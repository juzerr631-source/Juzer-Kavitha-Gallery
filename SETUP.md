# Two Perspectives — backend setup

The public site works as a demo until a **separate** Supabase project is connected. Do not reuse the physical-prints/orders database.

1. Create a new Supabase project for this gallery.
2. Run supabase-setup.sql in SQL Editor once. It defines the admin allowlist, photo table, RLS policies and public preview storage.
3. In Authentication > Users, manually create two email/password users for Juzer and Kavitha. Copy their UUIDs and insert them into public.gallery_admins using SQL Editor. Do not enable public signup.
4. Find Project Settings > API: copy the project URL and publishable (or legacy anon) key into config.js. These keys are designed to be public; NEVER use a service_role/secret key.
5. Visit admin.html, log in, upload reduced-size watermarked previews, and publish.
6. For commercial digital downloads, add a **separate private originals bucket and server-side authorization** later, alongside payments. Never upload original sellable files to the public previews bucket.

This is a staged build: no payments, no customer checkout, no high-resolution delivery, no secure original-file uploads. Public preview images are intentionally accessible and can be saved by visitors. GitHub Pages is static hosting; Supabase handles authentication and authorization.
