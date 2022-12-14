module IntacctRB
  class Employee < IntacctRB::Base
    def create
      response = send_xml('create') do |xml|
        xml.function(controlid: "1") {
          xml.send("create") {
            employee_xml(xml)
          }
        }
      end

      if successful?
        data = OpenStruct.new({
          id: response.at("//RECORDNO").try(:content),
          name: response.at("//PERSONALINFO/CONTACTNAME").try(:content),
          contact_id: response.at("//CONTACTKEY").try(:content),
          employee_id: response.at("//EMPLOYEEID").try(:content)
        })
      end

      return_result(response, data)
    end

    def get(options = {})
      # return false unless object.intacct_id.present?

      options[:fields] = [
        :employeeid,
        :contactname
      ] if options[:fields].nil?

      response = send_xml('get') do |xml|
        xml.function(controlid: "f4") {
          xml.read {
            xml.object 'EMPLOYEE'
            xml.keys object.try(:intacct_id) || options[:intacct_id]
            xml.fields '*'
          }
        }
      end

      if successful?
        data = OpenStruct.new({
          id: response.at("//EMPLOYEE/RECORDNO").try(:content),
          name: response.at("//EMPLOYEE/PERSONALINFO/CONTACTNAME").try(:content),
          contact_id: response.at("//EMPLOYEE/CONTACTKEY").try(:content),
          employee_id: response.at("//EMPLOYEE/EMPLOYEEID").try(:content)
        })
      end

      return_result(response, data)
    end

    def get_by_employee_id(options = {})
      # return false unless object.intacct_id.present?

      # options[:fields] = [
      #   :contactid,
      #   :contactname
      # ] if options[:fields].nil?

      response = send_xml('get') do |xml|
        xml.function(controlid: "f4") {
          xml.readByName {
            xml.object 'EMPLOYEE'
            xml.keys object.try(:employee_id) || options[:employee_id]
            xml.fields '*'
          }
        }
      end

      if successful?
        data = OpenStruct.new({
          id: response.at("//EMPLOYEE/RECORDNO").try(:content),
          name: response.at("//EMPLOYEE/PERSONALINFO/CONTACTNAME").try(:content),
          contact_id: response.at("//EMPLOYEE/CONTACTKEY").try(:content),
          employee_id: response.at("//EMPLOYEE/EMPLOYEEID").try(:content)
        })
      end

      return_result(response, data)
    end

    def get_list *fields
      #return false unless object.intacct_id.present?

      fields = [
        :customerid,
        :name,
        :termname
      ] if fields.empty?

      response = send_xml('get_list') do |xml|
        xml.function(controlid: "f4") {
          xml.get_list(object: "employee", maxitems: "2000", showprivate:"false") {
            # xml.fields {
            #   fields.each do |field|
            #     xml.field field.to_s
            #   end
            # }
          }
        }
      end
      return_result(response)
    end

    def update updated_employee = false
      @object = updated_employee if updated_employee
      return false unless object.intacct_id.present?
      response = send_xml('update') do |xml|
        xml.function(controlid: "1") {
          xml.update {
            employee_xml(xml)
          }
        }
      end

      return_result(response)
    end

    def delete
      return false unless object.intacct_id.present?

      response = send_xml('delete') do |xml|
        xml.function(controlid: "1") {
          xml.delete_employee(employeeid: intacct_id)
        }
      end

      return_result(response)
    end

    def employee_xml xml
      xml.employee {
        xml.recordno object.intacct_id if object.intacct_id
        xml.title object.title if object.title
        xml.personalinfo {
          xml.contactname object.name
        }
        xml.locationid object.location_id if object.location_id
        xml.departmentid object.departmentid if object.department_id
        xml.classid object.classid if object.department_id
        xml.supervisorid object.supervisorid if object.department_id
        xml.birthdate date_string(object.birthdate) if object.birthdate
        xml.startdate date_string(object.startdate) if object.startdate
        xml.enddate date_string(object.enddate) if object.enddate
        xml.terminationtype object.terminationtype if object.terminationtype
        xml.employeetype object.employeetype if object.employeetype
        xml.gender object.gender if object.gender
        xml.status object.status if object.status
        xml.currency object.currency if object.currency
      }
    end
  end
end
