import React, { useState, useEffect } from "react";
import { Form, Input, Button, Radio } from "antd";
import { useNavigate } from "react-router-dom";

type Gender = "male" | "female";

export interface Contact {
  name: string;
  email: string;
  gender: Gender;
  phoneNumber: string;
}

interface FormErrors {
  name?: string;
  email?: string;
  phoneNumber?: string;
}

const validateEmail = (email: string) => {
  const pattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
  return pattern.test(email);
};

function NewContactForm() {
  const navigate = useNavigate();

  const [formData, setFormData] = useState<Contact>({
    name: "",
    email: "",
    gender: "male",
    phoneNumber: "",
  });

  const [errors, setErrors] = useState<FormErrors>({});
  const [contacts, setContacts] = useState<Contact[]>(
    JSON.parse(localStorage.getItem("contacts") || "[]")
  );

  const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = event.target;
    setFormData((prevData) => ({ ...prevData, [name]: value }));
  };

  // Change handleValidation to return the errors
  const handleValidation = (
    name: string,
    value: string
  ): string | undefined => {
    switch (name) {
      case "name":
        if (!value) return "Name is required.";
        break;
      case "email":
        if (!validateEmail(value)) return "Invalid email format.";
        break;
      case "phoneNumber":
        if (!value) return "Phone number is required.";
        break;
      default:
        return;
    }
  };

  const handleSubmit = () => {
    const localErrors: FormErrors = {};

    for (const field in formData) {
      const error = handleValidation(field, formData[field as keyof Contact]);
      if (error) {
        localErrors[field as keyof FormErrors] = error;
      }
    }

    // Now, update the errors state
    setErrors(localErrors);

    // And then check if there are any errors before saving the contact
    if (!Object.values(localErrors).some(Boolean)) {
      setContacts((prevContacts) => [...prevContacts, formData]);

      setFormData({
        name: "",
        email: "",
        gender: "male",
        phoneNumber: "",
      });
    }
  };

  useEffect(() => {
    localStorage.setItem("contacts", JSON.stringify(contacts));
  }, [contacts]);

  return (
    <div
      style={{
        width: "100%",
        display: "flex",
        justifyContent: "center",
      }}
    >
      <Form onFinish={handleSubmit}>
        <Form.Item
          label="Имя"
          help={errors.name}
          validateStatus={errors.name ? "error" : "validating"}
        >
          <Input
            name="name"
            value={formData.name}
            onChange={handleInputChange}
            onBlur={(e) => handleValidation("name", e.target.value)}
          />
        </Form.Item>

        <Form.Item
          label="Электронная почта"
          help={errors.email}
          validateStatus={errors.email ? "error" : "validating"}
        >
          <Input
            name="email"
            value={formData.email}
            onChange={handleInputChange}
            onBlur={(e) => handleValidation("email", e.target.value)}
          />
        </Form.Item>

        <Form.Item label="Пол">
          <Radio.Group
            name="gender"
            value={formData.gender}
            onChange={handleInputChange as any}
          >
            <Radio value="male">Мужчина</Radio>
            <Radio value="female">Женщина</Radio>
          </Radio.Group>
        </Form.Item>

        <Form.Item
          label="Номер телефона"
          help={errors.phoneNumber}
          validateStatus={errors.phoneNumber ? "error" : "validating"}
        >
          <Input
            name="phoneNumber"
            value={formData.phoneNumber}
            onChange={handleInputChange}
            onBlur={(e) => handleValidation("phoneNumber", e.target.value)}
          />
        </Form.Item>

        <Form.Item>
          <Button type="primary" htmlType="submit" style={{ marginRight: 30 }}>
            Добавить
          </Button>
          <Button
            type="dashed"
            htmlType="submit"
            onClick={() => {
              navigate("/contacts");
            }}
          >
            Смотреть Контакты
          </Button>
        </Form.Item>
      </Form>
    </div>
  );
}

export default NewContactForm;
