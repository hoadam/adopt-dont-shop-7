require 'rails_helper'

RSpec.describe "Application Show Page" do
  let!(:application_1) {Application.create!(name: "Sally", street_address: "112 W 9th St.", city: "Kansas City", state: "MO", zip_code: "64105", description: "I love animals. Please let me have one.", status: "pending")}
  let!(:application_2) {Application.create!(name: "Marcus", street_address: "100 Hennepin Ave.", city: "Minneapolis", state: "MN", zip_code: "55401", description: "Dogs are the best. Please let me have one.", status: "in_progress")}

  let!(:shelter_1) {Shelter.create!(foster_program: true, name: "Adopters Unite", city: "Minneapolis", rank: 1 ) }
  let!(:pet_1) {shelter_1.pets.create!(adoptable: true, age: 3, breed: "doberman", name: "Rover")}
  let!(:pet_2) {shelter_1.pets.create!(adoptable: true, age: 2, breed: "dalmatian", name: "Pongo")}
  let!(:pet_3) {shelter_1.pets.create!(adoptable: true, age: 1, breed: "dalmatian", name: "Pongo II")}

  let!(:application_pet_1) {ApplicationPet.create!(pet: pet_1, application: application_1)}
  let!(:application_pet_2) {ApplicationPet.create!(pet: pet_2, application: application_2)}
  let!(:application_pet_3) {ApplicationPet.create!(pet: pet_3, application: application_2)}

  before do 
    visit "/applications/#{application_1.id}"
  end

  describe "As a Visitor" do
    describe "User Story 1 - display application info" do
      it "applicant's name" do
        expect(page).to have_content(application_1.name)
        expect(page).to_not have_content(application_2.name)
      end

      describe "applicant's address" do
        it "application's street address" do
          expect(page).to have_content(application_1.street_address)
          expect(page).to_not have_content(application_2.street_address)
        end

        it "application's city" do
          expect(page).to have_content(application_1.city)
          expect(page).to_not have_content(application_2.city)
        end

        it "application's state" do
          expect(page).to have_content(application_1.state)
          expect(page).to_not have_content(application_2.state)
        end

        it "application's zip" do
          expect(page).to have_content(application_1.zip_code)
          expect(page).to_not have_content(application_2.zip_code)
        end
      end

      it "application's description" do
        expect(page).to have_content(application_1.description)
        expect(page).to_not have_content(application_2.description)
      end

      describe "pets applied for" do
        it "lists pets names" do
          expect(page).to have_content(pet_1.name)
          expect(page).to_not have_content(pet_2.name)
        end

        it "links pet names' to pet's show page" do
          expect(page).to have_link("Rover")

          click_link "Rover"
          expect(current_path).to eq("/pets/#{pet_1.id}")
        end
      end

      it "applicantion's status" do
        expect(page).to have_content(application_1.status)
        expect(page).to_not have_content(application_2.status)
      end
    end

    describe "User Story 4" do
      describe "a section on the page to 'Add a Pet to this Application' where I can search for Pets by name" do
        it "takes me back to the application show page and I see the pets whose name matches my search" do
          expect(page).to have_content("Add a Pet to this Application")

          fill_in "pet_name", with: "Rover"
          click_on "Submit"

          expect(current_path).to eq("/applications/#{application_1.id}")
          expect(page).to have_content("Rover")
          expect(page).to_not have_content("Pongo")
        end
      end
    end

    describe "User Story 5 - add pet to application" do
      it "displays 'Adopt this Pet' button next to pet names" do
        fill_in "pet_name", with: "Pongo"
        click_on "Submit"

        within "#pet_#{pet_2.id}" do
          expect(page).to have_content("Adopt this Pet")
        end

        within "#pet_#{pet_3.id}" do
          expect(page).to have_content("Adopt this Pet")
        end
      end

      it "'Adopt this Pet' button adds that pet to application's show page" do
        pet_4 = shelter_1.pets.create!(adoptable: true, age: 3, breed: "doberman", name: "Rosco")
        fill_in "pet_name", with: "Rosco"
        click_on "Submit"

        within "#pet_#{pet_4.id}" do
          click_on "Adopt this Pet"
        end

        within("#pet_name_#{pet_4.id}") do
          expect(page).to have_content("#{pet_4.name}")
        end
        
        expect(current_path).to eq("/applications/#{application_1.id}")
      end
    end
  end
end
