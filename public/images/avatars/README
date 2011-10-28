The avatars in this folder were generated using Face Your Manga(http://www.faceyourmanga.com) -
a site that allows the composition of various features and accessories to create a cartoon
avatar.  Every attempt was made by the "artist" to avoid stereotypes while at the same time 
leveraging the uniqueness of each race, gender, and ethnicity.  No offense is intended by the 
use of a particular color, style, feature, etc.  Also note that the author is not a cartoonist,
fashion designer, or graphic artist, but rather a software engineer, so the quality and artistic 
value should be taken with several grains of salt.

To make sure that all of the patients in the database match with some image, queries were performed
to discover the unique combinations of age/sex/race/ethnisity.  These were then mapped to the avatars
as indicated in the table below.

Example query:
> db.records.find({"birthdate":{$lt: 752082900},"gender":"F","race":"Black or African American","ethnicity":"Not Hispanic or Latino"},{"last":1,"first":1,"ethnicity":1,"race":1,"gender":1}).sort({"race":"asc","ethnicity":"asc"}).count()
25

To determine whether the patient is a child or adult, the fact that 752082900 seconds ago is 18 years old (10/31/1993)


"race"=>"American Indian Or Alaska Native"
	ethnicity (all are) "Not Hispanic or Latino"
		  Man   - 6   indianman.png
		  Boy   - 0
		  Woman - 2   indianwoman.png
		  Girl  - 1   indiangirl.png

"race"=>"Asian", 
	"ethnicity (all are) "Not Hispanic or Latino"
		  Man   - 7   asianman.png
		  Boy   - 1   asianboy.png
		  Woman - 6   asianwoman.png
		  Girl  - 1   asiangirl.png

"race"=>"Black or African American", 
	"ethnicity"=>"Hispanic or Latino"
		  Man   - 0
		  Boy   - 0
		  Woman - 1   blackwomanhispanic.png
		  Girl  - 0
	"ethnicity"=>"Not Hispanic or Latino"
		  Man   - 21  blackman.png
		  Boy   - 2   blackboy.png
		  Woman - 25  blackwoman.png
		  Girl  - 1   blackgirl.png

"race"=>"Native Hawaiian or Other Pacific Islander", 
	"ethnicity" (all are) "Not Hispanic or Latino"
		  Man   - 5   hawaiianman.png
		  Boy   - 1   hawaiianboy.png
		  Woman - 11  hawaiianwoman.png
		  Girl  - 1   hawaiiangirl.png

"race"=>"Other Race", 
	"ethnicity"=>"Hispanic or Latino"
		  Man   - 15  othermanhispanic.png
		  Boy   - 2   otherboyhispanic.png
		  Woman - 14  otherwomanhispanic.png
		  Girl  - 3   othergirlhispanic.png
	"ethnicity"=>"Not Hispanic or Latino"
		  Man   - 6   otherman.png
		  Boy   - 1   otherboy.png
		  Woman - 2   otherwoman.png
		  Girl  - 1   othergirl.png

"race"=>"White", 
	"ethnicity"=>"Hispanic or Latino"
		  Man   - 3   whitemanhispanic.png
		  Boy   - 0
		  Woman - 1   whitewomanhispanic.png
		  Girl  - 0
"race"=>"White", 
	"ethnicity"=>"Not Hispanic or Latino"
		  Man   - 37  whiteman.png
		  Boy   - 2   whiteboy.png
		  Woman - 41  whitewoman.png
		  Girl  - 5   whitegirl.png

If, for some reason we cannot determine the race/age/gender/ethnicity of a patient,
there is a "catch all" image that will be assigned:
      	   	       	     unknown.png

