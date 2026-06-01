# Design Specification: Honkai Star Retail (HSR) UI/UX
**Target Framework:** Flutter SDK 3.32.2
**Aesthetic Goal:** Replicate the *Honkai: Star Rail* in-game menu and terminal interfaces.

## 1. Global Theming & Properties
To satisfy the rubric requirement of altering 2-4 visual properties, this implementation overrides the default Material theme with specific HSR-inspired properties:

* **Font Family:** `Rajdhani` or `Titillium Web` (via `google_fonts` package). These provide the squared-off, technical look of the HSR UI.
* **Background Color (ThemeData.scaffoldBackgroundColor):** `#0B0D17` (Deep Space Black).
* **Alpha/Tint (Glassmorphism):** Menus and cards use `#1E2233` with `0.6` to `0.8` opacity, backed by a `BackdropFilter` (blur).
* **Accent Color (Gold):** `#D4AF37` (Used for active states, borders, and primary buttons).

## 2. Core UI Components (Minimum 5 Required)
You must build these as reusable stateless/stateful widgets to meet the rubric's 5 component minimum.

### 2.1. `HsrGlassCard` (Container)
* **Visuals:** Replicates the grid buttons seen in the provided reference image.
* **Implementation:** A `Container` wrapped in a `ClipRRect` and `BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10))`.
* **Border:** 0.5px solid border using a very faint white/grey (`Colors.white24`), changing to Accent Gold when focused/tapped.

### 2.2. `HsrGridTile` (Catalog Item)
* **Visuals:** Based on the square icons in the reference image (e.g., "Shop", "Warp").
* **Layout:** A vertical `Column` inside an `HsrGlassCard`. Top 70% is the resource `image`, bottom 30% is a `Container` with a slightly darker tint housing the resource `name` and `price`.
* **Typography:** Item name in `Rajdhani` Semi-Bold (White), Price in Accent Gold.

### 2.3. `HsrTerminalTextField` (Input Validation)
* **Visuals:** Minimalist input for the Admin CRUD forms.
* **Implementation:** Removes the standard Material box. Uses an `InputDecoration` with `border: InputBorder.none` and a custom bottom border that glows gold when focused.
* **Friction Note:** Ensure the contrast between the input text and the dark background passes WCAG standards, or you will fail the usability requirement.

### 2.4. `HsrActionButton` (Primary CTA)
* **Visuals:** Used for "Buy" and "Login" actions.
* **Implementation:** A flat button with an Accent Gold background and black text.
* **Shape:** Instead of rounded corners, use `BeveledRectangleBorder` with a small radius to create the sharp, chamfered edge look common in HoYoverse UI.

### 2.5. `HsrStockBadge` (Status Indicator)
* **Visuals:** A small, angled tag indicating `type` (Resource/Light Cone) or `stock` levels.
* **Implementation:** A `Container` with a `Transform` (skew/slant) applied. Red if `stock == 0`, Green/Gold if `stock > 0`.

## 3. Page Layouts (Minimum 5 Required)
The application requires at least 5 distinct pages.

### 3.1. Astral Gateway (Auth / Login Page)
* **Background:** The cropped HSR train/planet background image (fullscreen).
* **Content:** A centered `HsrGlassCard` containing the local login `HsrTerminalTextField`s (Username/Password), the `HsrActionButton` for local login, and a secondary button for OAuth (Google/Facebook).

### 3.2. Retail Manifest (User Catalog Page)
* **Layout:** A `GridView.builder` with `crossAxisCount: 3` (or 2 depending on screen width) to replicate the phone menu structure in your reference image.
* **Content:** Populated with `HsrGridTile` widgets mapping over the database resources. Each tile displays the `image`, `name`, and `price`.

### 3.3. Data Bank (Resource Detail Page)
* **Layout:** Triggered by tapping an item in the Catalog.
* **Content:**
    * Top: Large Hero image of the resource.
    * Middle: Title, `HsrStockBadge` showing stock, and `description`.
    * Bottom Fixed Bar: Quantity selector and a large `HsrActionButton` to execute the purchase (triggers the Backend API constraint).

### 3.4. Admin Dashboard (Inventory List)
* **Layout:** A technical, data-dense `ListView.builder`.
* **Content:** Each row shows the resource `id`, `name`, `stock`, and `price`. Includes two icon buttons per row: Edit (Pencil) and Delete (Trash).
* **Security:** This page must fetch data using the generated 20-character alphanumeric Bearer Token.

### 3.5. Synthesizer (Admin Editor Page)
* **Layout:** A scrollable form utilizing `HsrTerminalTextField` for all schema requirements (`name`, `type`, `description`, `stock`, `image` URL, `price`).
* **Validation:** Must implement the 3 required data validations here (e.g., `price` > 0, `stock` >= 0, fields not empty) and show specific error SnackBars if they fail.
* **Action:** An `HsrActionButton` to trigger the POST/PUT/PATCH request to your Node.js backend.

## 4. Technical Friction & Implementation Warnings
1.  **Overuse of BackdropFilter:** The `BackdropFilter` (glass effect) is computationally expensive in Flutter's rendering pipeline. Wrapping 20 items in a `GridView` with heavy blurs *will* cause raster thread jank on lower-end mobile devices. Limit the blur radius (`sigmaX`/`Y` < 5) and only use it on larger layout elements (like the App Bar or modal backgrounds) rather than every single grid tile