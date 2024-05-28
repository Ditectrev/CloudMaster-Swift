import Foundation

enum CourseCompany: String, Codable, Hashable, CaseIterable {
    case aws = "Amazon Web Services"
    case azure = "Microsoft Azure"
    case gcp = "Google Cloud Platform"
}


enum CodingKeys: String, CodingKey {
    case question, choices, multipleResponse = "multiple_response", responseCount = "response_count"
}

struct Course: Codable, Hashable, Identifiable {
    let fullName: String
    let company: CourseCompany
    let description: String
    var questionURL: String
    let shortName: String
    let url: String
    let exam: Exam
    let id = UUID() // Add this line

    // Add this for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(fullName)
        hasher.combine(company)
        hasher.combine(description)
        hasher.combine(questionURL)
        hasher.combine(shortName)
        hasher.combine(url)
    }

    // Add this for Hashable conformance
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.fullName == rhs.fullName &&
               lhs.company == rhs.company &&
               lhs.description == rhs.description &&
               lhs.questionURL == rhs.questionURL &&
               lhs.shortName == rhs.shortName &&
        lhs.url == rhs.url
    }
    
    
    struct Exam: Codable {
        let quick: ExamDetail
        let intermediate: ExamDetail
        let real: ExamDetail
    }

    struct ExamDetail: Codable {
        let time: Int
        let questionCount: Int
    }
}
extension Course {
    static let allCourses = [
        Course(
            fullName: "AWS Certified Advanced Networking Specialty",
            company: .aws,
            description: "Validates expertise in designing and maintaining AWS network architecture, including hybrid IT, routing, and security.",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Amazon-Web-Services-Certified-AWS-Certified-Advanced-Networking-Specialty-ANS-C01-Practice-Test-Exam/main/README.md",
            shortName: "ANS-C01",
            url: "https://aws.amazon.com/certification/certified-advanced-networking-specialty/",
            exam: Exam(
                quick: ExamDetail(time: 57, questionCount: 22),
                intermediate: ExamDetail(time: 119, questionCount: 46),
                real: ExamDetail(time: 170, questionCount: 65)
            )
        ),
        Course(
            fullName: "AWS Certified Solutions Architect Associate",
            company: .aws,
            description: "Covers designing and deploying scalable, highly available, and fault-tolerant systems on AWS.",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/AWS-Certified-Solutions-Architect-Associate-SAA-C03-Practice-Tests-Exams-Questions-Answers/main/README.md",
            shortName: "SAA-C03",
            url: "https://aws.amazon.com/certification/certified-solutions-architect-associate/",
            exam: Exam(
                quick: ExamDetail(time: 40, questionCount: 20),
                intermediate: ExamDetail(time: 84, questionCount: 49),
                real: ExamDetail(time: 120, questionCount: 65)
            )
        ),
        Course(
            fullName: "AWS Certified Cloud Practitioner",
            company: .aws,
            description: "Provides a foundational understanding of AWS cloud concepts, services, security, architecture, pricing, and support.",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Amazon-Web-Services-AWS-Certified-Cloud-Practitioner-CLF-C02-Practice-Tests-Exams-Questions-Answers/main/README.md",
            shortName: "CLF-C02",
            url: "https://aws.amazon.com/certification/certified-cloud-practitioner/",
            exam: Exam(
                quick: ExamDetail(time: 30, questionCount: 20),
                intermediate: ExamDetail(time: 42, questionCount: 42),
                real: ExamDetail(time: 90, questionCount: 65)
            )
        ),
        Course(
            fullName: "Azure Fundamentals",
            company: .azure,
            description: "Covers general cloud concepts and core Azure services, pricing, and support.",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Microsoft-Azure-AZ-900-Microsoft-Azure-Fundamentals-Practice-Tests-Exams-Questions-Answers/main/README.md",
            shortName: "AZ-900",
            url: "https://learn.microsoft.com/en-us/certifications/azure-fundamentals/",
            exam: Exam(
                quick: ExamDetail(time: 20, questionCount: 20),
                intermediate: ExamDetail(time: 35, questionCount: 42),
                real: ExamDetail(time: 60, questionCount: 60)
            )
        ),
        Course(
            fullName: "Azure Designing and Implementing Microsoft DevOps Solutions",
            company: .azure,
            description: "Validates skills in DevOps practices, continuous integration, delivery, and infrastructure as code.",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Microsoft-Azure-AZ-400-Designing-and-Implementing-Microsoft-DevOps-Solutions-Practice-Tests-Exams-QA/main/README.md",
            shortName: "AZ-400",
            url: "https://learn.microsoft.com/en-us/certifications/devops-engineer/",
            exam: Exam(
                quick: ExamDetail(time: 65, questionCount: 20),
                intermediate: ExamDetail(time: 91, questionCount: 42),
                real: ExamDetail(time: 120, questionCount: 60)
            )
        ),
        Course(
            fullName: "Azure Developing Solutions for Microsoft Azure",
            company: .azure,
            description: "Covers designing, building, testing, and maintaining cloud applications on Azure.",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Microsoft-Azure-AZ-204-Developing-Solutions-for-Microsoft-Azure-Practice-Tests-Exams-Question-Answer/main/README.md",
            shortName: "AZ-204",
            url: "https://learn.microsoft.com/en-us/certifications/azure-developer/",
            exam: Exam(
                quick: ExamDetail(time: 50, questionCount: 40),
                intermediate: ExamDetail(time: 126, questionCount: 56),
                real: ExamDetail(time: 180, questionCount: 65)
            )
        ),
        Course(
            fullName: "Azure Infrastructure Solutions",
            company: .azure,
            description: "Focuses on designing cloud and hybrid solutions on Azure.",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Microsoft-Azure-AZ-305-Designing-Microsoft-Azure-Infrastructure-Solutions-Practice-Tests-Exams-QA/main/README.md",
            shortName: "AZ-305",
            url: "https://learn.microsoft.com/en-us/certifications/azure-solutions-architect/",
            exam: Exam(
                quick: ExamDetail(time: 55, questionCount: 20),
                intermediate: ExamDetail(time: 98, questionCount: 42),
                real: ExamDetail(time: 120, questionCount: 60)
            )
        ),
        Course(
            fullName: "Azure Windows Server Hybrid Administrator",
            company: .azure,
            description: "Covers managing core Windows Server workloads using Azure services.",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Microsoft-Azure-AZ-800-Windows-Server-Hybrid-Administrator-Practice-Tests-Exams-Questions-Answers/main/README.md",
            shortName: "AZ-800",
            url: "https://learn.microsoft.com/en-us/certifications/windows-server-hybrid-administrator-associate/",
            exam: Exam(
                quick: ExamDetail(time: 60, questionCount: 20),
                intermediate: ExamDetail(time: 105, questionCount: 42),
                real: ExamDetail(time: 150, questionCount: 60)
            )
        ),
        Course(
            fullName: "Azure Administrator",
            company: .azure,
            description: "Validates managing cloud services covering storage, networking, and compute on Azure.",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Microsoft-Azure-AZ-104-Microsoft-Azure-Administrator-Practice-Tests-Exams-Questions-Answers/main/README.md",
            shortName: "AZ-104",
            url: "https://learn.microsoft.com/en-us/certifications/azure-administrator/",
            exam: Exam(
                quick: ExamDetail(time: 60, questionCount: 20),
                intermediate: ExamDetail(time: 105, questionCount: 42),
                real: ExamDetail(time: 150, questionCount: 60)
            )
        ),
        Course(
            fullName: "Azure Security Engineer",
            company: .azure,
            description: "Covers implementing security controls, managing identity and access, and protecting data on Azure.",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Microsoft-Azure-AZ-500-Azure-Security-Engineer-Practice-Tests-Exams-Questions-Answers/main/README.md",
            shortName: "AZ-500",
            url: "https://learn.microsoft.com/en-us/certifications/azure-security-engineer/",
            exam: Exam(
                quick: ExamDetail(time: 60, questionCount: 20),
                intermediate: ExamDetail(time: 105, questionCount: 42),
                real: ExamDetail(time: 150, questionCount: 60)
            )
        ),
        Course(
            fullName: "Associate Cloud Engineer",
            company: .gcp,
            description: "Validates deploying, monitoring, and managing solutions on Google Cloud Platform.",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Google-Cloud-Platform-GCP-Associate-Cloud-Engineer-Practice-Tests-Exams-Questions-Answers/main/README.md",
            shortName: "ACE",
            url: "https://cloud.google.com/certification/cloud-engineer",
            exam: Exam(
                quick: ExamDetail(time: 40, questionCount: 20),
                intermediate: ExamDetail(time: 84, questionCount: 42),
                real: ExamDetail(time: 120, questionCount: 60)
            )
        )
    ]
}
