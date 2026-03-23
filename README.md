# MentorTrack - Full Stack Flutter & Node.js Application

A mentorship management system built with Flutter (Frontend) and Express.js with Supabase (Backend).

## 🚀 Getting Started

### 1. Backend Setup (`backend-express/`)

1.  **Install Dependencies:**
    ```bash
    cd backend-express
    npm install
    ```
2.  **Environment Variables:**
    Create a `.env` file in `backend-express/` with:
    ```env
    PORT=5000
    SUPABASE_URL=your_supabase_url
    SUPABASE_KEY=your_supabase_anon_key
    JWT_SECRET=your_jwt_secret
    ```
3.  **Database Migration:**
    Copy the contents of `supabase_setup.sql` into the Supabase SQL Editor and run it to create the required tables.
4.  **Seed Data:**
    Populate the database with test students, mentors, and sample records:
    ```bash
    npm run seed
    ```
5.  **Start Server:**
    ```bash
    npm start
    ```

---

### 2. Physical Device Connectivity (USB Debugging)

To connect your physical Android device to the local backend:

1.  **Enable USB Debugging** on your phone.
2.  **Create a Tunnel:** Run this command on your PC (find `adb` in your Android SDK platform-tools):
    ```powershell
    # Windows Example:
    & "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe" reverse tcp:5000 tcp:5000
    ```
    *This maps `localhost:5000` on your phone to `localhost:5000` on your PC.*

---

### 3. Frontend Setup (`frontend/`)

1.  **Install Flutter dependencies:**
    ```bash
    cd frontend
    flutter pub get
    ```
2.  **Run the app:**
    ```bash
    flutter run
    ```

---

## 🔑 Test Credentials

All accounts use the password: `password123`

| Role | Email |
| :--- | :--- |
| **Mentor** | `mentor@pvppcoe.ac.in` |
| **Student 1** | `student1@pvppcoe.ac.in` |
| **Student 2** | `student2@pvppcoe.ac.in` |

---

## 🌐 Connecting from Other Devices

If you want to run the app on a device **not** connected via USB (e.g., another person's phone on the same Wi-Fi):

1.  Find your PC's **LAN IP Address** (e.g., `192.168.1.5`).
2.  In `frontend/lib/services/api_service.dart`, change:
    ```dart
    static const String baseUrl = 'http://your_lan_ip:5000';
    ```
3.  Ensure your PC's firewall allows incoming traffic on port `5000`.
