// Ensure jQuery is available globally before any plugins that depend on it
import "jquery2";

// Core libraries
import "@popperjs/core";
import "bootstrap";

// Plugins that depend on jQuery
import "datatables";
import "jquery-ui";
import "parsleyjs";

// Other app JS
import "@hotwired/turbo-rails";
import "dragon-drop/dragon-drop";
import "controllers";

// import local-time
import LocalTime from "local-time";
LocalTime.start();
