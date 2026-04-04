# Mentor Mentee App

Full-stack mentor-mentee management system with:

- `frontend/`: Flutter app
- `backend/`: Node.js + Express API using PostgreSQL via Supabase

## Repo Structure

```text
mentor-mentee-app/
  backend/   # Render service target
  frontend/  # Flutter client
  render.yaml
```

## Backend Setup

```bash
cd backend
npm install
```

Create `backend/.env`:

```env
PORT=5000
DATABASE_URL=your_supabase_postgres_connection_string
JWT_SECRET=your_jwt_secret
EMAIL_SERVICE=gmail
EMAIL_USER=your_email_address
EMAIL_PASS=your_email_app_password
```

Run the backend:

```bash
cd backend
npm start
```

## Frontend Setup

```bash
cd frontend
flutter pub get
flutter run
```

Update the API base URL in the Flutter app when needed so it points to your running backend.

## Collaborator Notes

- Do not commit `.env` files or secrets.
- Install dependencies locally with `npm install` in `backend/` and `flutter pub get` in `frontend/`.
- The backend is intended to run against Supabase PostgreSQL, not the old local SQLite files.

## Deploy Backend On Render

This repo includes `render.yaml` for the backend service. The service root is `backend/`.

Required environment variables on Render:

- `DATABASE_URL`
- `JWT_SECRET`
- `EMAIL_SERVICE`
- `EMAIL_USER`
- `EMAIL_PASS`

Optional:

- `NODE_ENV=production`

Health check endpoint:

- `/health`
