// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application";
import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading";

// Defer loading controllers until they're encountered in the DOM to reduce
// initial network requests and parse time. This improves performance when
// many controllers exist but are not used on every page.
lazyLoadControllersFrom("controllers", application);
