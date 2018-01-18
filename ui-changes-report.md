UI Observations and Proposed Changes

Favorite Stars work well against the dark green background, but are a bit bright against the white:
  - Experiment with different shades of the same color

A single Breadcrumb is not clickable and it's a bit hard to see that that's the case. Even more so, when its shaded and unclickable, it doesn't quite match how the header shades the same way but is still clickable.
  - Experiment with the color grading, potential clear background and border instead, etc. Compare to the header.
  - In my own experimentation, I got prettygood results from the following modification:
    - Current breadcrumb: background-color: #fff, color: #666, font-weight: bold

Hyperlinks are not pronounced enough against other body text, particularly in the middle of paragraphs
  - Experiment with weight, underline, and color grade to differentiate it better as a link.
  - In my own experimentation so far, changing font colors seems to be a bit dangerous, and underline with no hover feels too "web 1.0". Giving font-weight:bold works well in most cases, but not to product test task links. This links seem distracting and out of place with bold text.

The cert-bar for a product test is potentially redundant, as the information for the certifications being checked it right below. It's also unclear if it's clickable, and unclear which are selected
  - Either add borders and remove background color (which makes it look like a link), or delete it.
  - In my own experimentation so far, deleting it seems to work well.

In a task view, the ability to change tasks for a measure is unclear until you hover over that task.
  - Turn either the header for it (e.g. "C1 and C2") or the "start" text into the same button format
  - In my own experimentation, doing it for "start" span seems to be more consistent and least incongruent to the rest of the view (making it a button instead of a span, giving it the classes "btn btn-default", etc.)

On the Master Patient List, Annual Update Bundle section has some weird styling. Namely, padding on the subtext instead of the entire div is strange.
  - Giving the entire section the same padding seems to fix the issue for me, and fixes another problem I had where the download button seemed too small (turns out, it wasn't a problem in itself but stuck out alongside the padding oddity).