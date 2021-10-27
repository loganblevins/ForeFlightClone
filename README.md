# Logan G. Blevins

## Building

- Select Xcode 13 (13A233) toolchain
    - Debug
        - Using Xcode GUI: Product-->Build
    - Release
        - Using Xcode GUI: Product-->Archive
    
## Design

I attacked this project with the MVVM architecture (Model, View, View Model).
Apple suggests MVC (Model, View, Controller), but it tends to translate to Massive View Controller.
Attached is a simple diagram of the architecture.

[![](https://mermaid.ink/img/eyJjb2RlIjoiZ3JhcGggVERcbiAgICBBMCgoRW50cnkgUG9pbnQpKSAtLS0gQVtNYWluVmlld0NvbnRyb2xsZXJdXG4gICAgQSAtLT4gfE93bnN8IEJbTWFpblZpZXdNb2RlbF1cbiAgICBCIC0tPiB8T3duc3wgQ1tQZXJzaXN0ZW5jZV1cbiAgICBCIC0tPiB8T3duc3wgRFtXZWF0aGVyQVBJXVxuICAgIEQgLS0-IHxPd25zfCBFW1JlcXVlc3Rvcl1cbiAgICBCIC0uLT4gfFVwZGF0ZXN8IEFcbiAgICBDIC0uLT4gfFVwZGF0ZXN8IEJcblxuICAgIEExW0RldGFpbFZpZXdDb250cm9sbGVyXSAtLT4gfE93bnN8IEIxW0RldGFpbFZpZXdNb2RlbF1cbiAgICAiLCJtZXJtYWlkIjp7InRoZW1lIjoiZGVmYXVsdCJ9LCJ1cGRhdGVFZGl0b3IiOmZhbHNlLCJhdXRvU3luYyI6dHJ1ZSwidXBkYXRlRGlhZ3JhbSI6ZmFsc2V9)](https://mermaid.live/edit#eyJjb2RlIjoiZ3JhcGggVERcbiAgICBBMCgoRW50cnkgUG9pbnQpKSAtLS0gQVtNYWluVmlld0NvbnRyb2xsZXJdXG4gICAgQSAtLT4gfE93bnN8IEJbTWFpblZpZXdNb2RlbF1cbiAgICBCIC0tPiB8T3duc3wgQ1tQZXJzaXN0ZW5jZV1cbiAgICBCIC0tPiB8T3duc3wgRFtXZWF0aGVyQVBJXVxuICAgIEQgLS0-IHxPd25zfCBFW1JlcXVlc3Rvcl1cbiAgICBCIC0uLT4gfFVwZGF0ZXN8IEFcbiAgICBDIC0uLT4gfFVwZGF0ZXN8IEJcblxuICAgIEExW0RldGFpbFZpZXdDb250cm9sbGVyXSAtLT4gfE93bnN8IEIxW0RldGFpbFZpZXdNb2RlbF1cbiAgICAiLCJtZXJtYWlkIjoie1xuICBcInRoZW1lXCI6IFwiZGVmYXVsdFwiXG59IiwidXBkYXRlRWRpdG9yIjpmYWxzZSwiYXV0b1N5bmMiOnRydWUsInVwZGF0ZURpYWdyYW0iOmZhbHNlfQ)

I initially wanted to display the weather as a nice table view, but quickly realized that was out of scope.
I found that some airports don't have a METAR (conditions) section and sometimes don't have a TAF (forecast).
This is especially true of small, rural airports. Further, some sections such as cloud layers,
appear to have a version 1 and version 2 representing similar concepts. I wasn't quite sure how to properly handle 
this due to possible unexpected data changes in the JSON that I may not know about.
I found that there was not enough time to account for all variations of the data in a nice table view format.
I was also afraid that if I created a set of classes using Codable, it would be too rigid and if testing with airports I haven't been able to try, yielding different data, it may break. All of this to say, with the lack of API documentation with a sort of "data contract" of what to expect for the weather,
I decided to display weather in the simplest and safest format. If time allowed, this could be improved.

## Attributions

- https://www.hackingwithswift.com/read/38/10/optimizing-core-data-performance-using-nsfetchedresultscontroller
- https://stackoverflow.com/questions/65950123/custom-combine-ratelimitedscheduler 
- https://stackoverflow.com/questions/19082963/how-to-make-completely-transparent-navigation-bar-in-ios-7 
- https://foreflight.com/about/media-kit/
- https://github.com/Alamofire/Alamofire
- https://mermaid.live


## Known Issues

To my working knowledge, there are no known _issues_ at this time of writing.

Some level of input validation has been implemented.
Various devices over a couple different iOS versions have been tested.
Testing without internet connection has been tested as well.

I would be interested in trying a very large data import of something in the order
of hundreds or thousands of airport entries. The fetched results controller is currently not limiting its
number of fetched objects - rather it fetches them all at once. This is fine for this project, but in
an iterative approach, it might be worth batching the fetches. If there are large volumes of airport entries,
we may not need them all at once anyway because only a subset of them are actually visible to the user at a 
given time in the table view. Maybe we could only fetch those that are currently in view or will become in view soon,
to reduce overhead with the fetched results controller. This is especially important because the fetched results 
controller is using the view context, which must run on the main queue - running the risk for UI blockage in some cases.

Further, I would be curious to see how the automatic update logic behaves in cases of very large volumes of objects.
I added some measure of nudging the compiler that I want memory released on short term intervals.
In my time working with Swift, I've found that there is still some usage needed of autoreleasepool
when dealing with objects that are still implemented in Objective-C under the hood, especially when 
there are many repeated operations occuring within a given scope.
This is likely an area that could be improved later if time allowed.

## Notes

- Supports iOS 13+ and is built with the iOS 15 SDK
- Supports iPhone and iPad
- Supports portrait orientation only for speed of delivery
- Not intended to support slide over or split view
- Tested on:
    - Physical iPhone 11 Pro Max (iOS 15) and iPad 5th gen (iOS 14.8)
    - Various simulators included in Xcode 13
