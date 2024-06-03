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
    let id = UUID() // Add this line
    let fullName: String
    let shortName: String
    let description: String
    let company: CourseCompany
    var repositoryURL: String
    var questionURL: String
    let url: String
    let exam: Exam
    var lastUpdate: Date?

    // Add this for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(fullName)
        hasher.combine(company)
        hasher.combine(description)
        hasher.combine(questionURL)
        hasher.combine(repositoryURL)
        hasher.combine(shortName)
        hasher.combine(url)
    }

    // Add this for Hashable conformance
    static func == (lhs: Course, rhs: Course) -> Bool {
        return  lhs.fullName == rhs.fullName &&
                lhs.company == rhs.company &&
                lhs.description == rhs.description &&
                lhs.questionURL == rhs.questionURL &&
                lhs.repositoryURL == rhs.repositoryURL &&
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
            shortName: "ANS-C01",
            description: "Validates expertise in designing and maintaining AWS network architecture, including hybrid IT, routing, and security.",
            company: .aws,
            repositoryURL: "https://github.com/Ditectrev/Amazon-Web-Services-Certified-AWS-Certified-Advanced-Networking-Specialty-ANS-C01-Practice-Test-Exam",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Amazon-Web-Services-Certified-AWS-Certified-Advanced-Networking-Specialty-ANS-C01-Practice-Test-Exam/main/README.md",
            url: "https://aws.amazon.com/certification/certified-advanced-networking-specialty/",
            exam: Exam(
                quick: ExamDetail(time: 57, questionCount: 22),
                intermediate: ExamDetail(time: 119, questionCount: 46),
                real: ExamDetail(time: 170, questionCount: 65)
            ),
            lastUpdate: nil
        ),
        Course(
            fullName: "AWS Certified Solutions Architect Associate",
            shortName: "SAA-C03",
            description: "Covers designing and deploying scalable, highly available, and fault-tolerant systems on AWS.",
            company: .aws,
            repositoryURL: "https://github.com/Ditectrev/AWS-Certified-Solutions-Architect-Associate-SAA-C03-Practice-Tests-Exams-Questions-Answers",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/AWS-Certified-Solutions-Architect-Associate-SAA-C03-Practice-Tests-Exams-Questions-Answers/main/README.md",
            url: "https://aws.amazon.com/certification/certified-solutions-architect-associate/",
            exam: Exam(
                quick: ExamDetail(time: 40, questionCount: 20),
                intermediate: ExamDetail(time: 84, questionCount: 49),
                real: ExamDetail(time: 120, questionCount: 65)
            ),
            lastUpdate: nil
        ),
        Course(
            fullName: "AWS Certified Cloud Practitioner",
            shortName: "CLF-C02",
            description: "Provides a foundational understanding of AWS cloud concepts, services, security, architecture, pricing, and support.",
            company: .aws,
            repositoryURL: "https://github.com/Ditectrev/Amazon-Web-Services-AWS-Certified-Cloud-Practitioner-CLF-C02-Practice-Tests-Exams-Questions-Answers",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Amazon-Web-Services-AWS-Certified-Cloud-Practitioner-CLF-C02-Practice-Tests-Exams-Questions-Answers/main/README.md",
            url: "https://aws.amazon.com/certification/certified-cloud-practitioner/",
            exam: Exam(
                quick: ExamDetail(time: 30, questionCount: 20),
                intermediate: ExamDetail(time: 42, questionCount: 42),
                real: ExamDetail(time: 90, questionCount: 65)
            ),
            lastUpdate: nil
        ),
        Course(
            fullName: "Azure Fundamentals",
            shortName: "AZ-900",
            description: "Covers general cloud concepts and core Azure services, pricing, and support.",
            company: .azure,
            repositoryURL: "https://github.com/Ditectrev/Microsoft-Azure-AZ-900-Microsoft-Azure-Fundamentals-Practice-Tests-Exams-Questions-Answers",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Microsoft-Azure-AZ-900-Microsoft-Azure-Fundamentals-Practice-Tests-Exams-Questions-Answers/main/README.md",
            url: "https://learn.microsoft.com/en-us/certifications/azure-fundamentals/",
            exam: Exam(
                quick: ExamDetail(time: 20, questionCount: 20),
                intermediate: ExamDetail(time: 35, questionCount: 42),
                real: ExamDetail(time: 60, questionCount: 60)
            ),
            lastUpdate: nil
        ),
        Course(
            fullName: "Azure Designing and Implementing Microsoft DevOps Solutions",
            shortName: "AZ-400",
            description: "Validates skills in DevOps practices, continuous integration, delivery, and infrastructure as code.",
            company: .azure,
            repositoryURL: "https://github.com/Ditectrev/Microsoft-Azure-AZ-400-Designing-and-Implementing-Microsoft-DevOps-Solutions-Practice-Tests-Exams-QA",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Microsoft-Azure-AZ-400-Designing-and-Implementing-Microsoft-DevOps-Solutions-Practice-Tests-Exams-QA/main/README.md",
            url: "https://learn.microsoft.com/en-us/certifications/devops-engineer/",
            exam: Exam(
                quick: ExamDetail(time: 65, questionCount: 20),
                intermediate: ExamDetail(time: 91, questionCount: 42),
                real: ExamDetail(time: 120, questionCount: 60)
            ),
            lastUpdate: nil
        ),
        Course(
            fullName: "Azure Developing Solutions for Microsoft Azure",
            shortName: "AZ-204",
            description: "Covers designing, building, testing, and maintaining cloud applications on Azure.",
            company: .azure,
            repositoryURL: "https://github.com/Ditectrev/Microsoft-Azure-AZ-204-Developing-Solutions-for-Microsoft-Azure-Practice-Tests-Exams-Question-Answer",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Microsoft-Azure-AZ-204-Developing-Solutions-for-Microsoft-Azure-Practice-Tests-Exams-Question-Answer/main/README.md",
            url: "https://learn.microsoft.com/en-us/certifications/azure-developer/",
            exam: Exam(
                quick: ExamDetail(time: 50, questionCount: 40),
                intermediate: ExamDetail(time: 126, questionCount: 56),
                real: ExamDetail(time: 180, questionCount: 65)
            ),
            lastUpdate: nil
        ),
        Course(
            fullName: "Azure Infrastructure Solutions",
            shortName: "AZ-305",
            description: "Focuses on designing cloud and hybrid solutions on Azure.",
            company: .azure,
            repositoryURL: "https://github.com/Ditectrev/Microsoft-Azure-AZ-305-Designing-Microsoft-Azure-Infrastructure-Solutions-Practice-Tests-Exams-QA",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Microsoft-Azure-AZ-305-Designing-Microsoft-Azure-Infrastructure-Solutions-Practice-Tests-Exams-QA/main/README.md",
            url: "https://learn.microsoft.com/en-us/certifications/azure-solutions-architect/",
            exam: Exam(
                quick: ExamDetail(time: 55, questionCount: 20),
                intermediate: ExamDetail(time: 98, questionCount: 42),
                real: ExamDetail(time: 120, questionCount: 60)
            ),
            lastUpdate: nil
        ),
        Course(
            fullName: "Azure Windows Server Hybrid Administrator",
            shortName: "AZ-800",
            description: "Covers managing core Windows Server workloads using Azure services.",
            company: .azure,
            repositoryURL: "https://github.com/Ditectrev/Microsoft-Azure-AZ-800-Windows-Server-Hybrid-Administrator-Practice-Tests-Exams-Questions-Answers",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Microsoft-Azure-AZ-800-Windows-Server-Hybrid-Administrator-Practice-Tests-Exams-Questions-Answers/main/README.md",
            url: "https://learn.microsoft.com/en-us/certifications/windows-server-hybrid-administrator-associate/",
            exam: Exam(
                quick: ExamDetail(time: 60, questionCount: 20),
                intermediate: ExamDetail(time: 105, questionCount: 42),
                real: ExamDetail(time: 150, questionCount: 60)
            ),
            lastUpdate: nil
        ),
        Course(
            fullName: "Azure Administrator",
            shortName: "AZ-104",
            description: "Validates managing cloud services covering storage, networking, and compute on Azure.",
            company: .azure,
            repositoryURL: "https://github.com/Ditectrev/Microsoft-Azure-AZ-104-Microsoft-Azure-Administrator-Practice-Tests-Exams-Questions-Answers",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Microsoft-Azure-AZ-104-Microsoft-Azure-Administrator-Practice-Tests-Exams-Questions-Answers/main/README.md",
            url: "https://learn.microsoft.com/en-us/certifications/azure-administrator/",
            exam: Exam(
                quick: ExamDetail(time: 60, questionCount: 20),
                intermediate: ExamDetail(time: 105, questionCount: 42),
                real: ExamDetail(time: 150, questionCount: 60)
            ),
            lastUpdate: nil
        ),
        Course(
            fullName: "Azure Security Engineer",
            shortName: "AZ-500",
            description: "Covers implementing security controls, managing identity and access, and protecting data on Azure.",
            company: .azure,
            repositoryURL: "https://github.com/Ditectrev/Microsoft-Azure-AZ-500-Azure-Security-Engineer-Practice-Tests-Exams-Questions-Answers",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Microsoft-Azure-AZ-500-Azure-Security-Engineer-Practice-Tests-Exams-Questions-Answers/main/README.md",
            url: "https://learn.microsoft.com/en-us/certifications/azure-security-engineer/",
            exam: Exam(
                quick: ExamDetail(time: 60, questionCount: 20),
                intermediate: ExamDetail(time: 105, questionCount: 42),
                real: ExamDetail(time: 150, questionCount: 60)
            )
        ),
        Course(
            fullName: "Associate Cloud Engineer",
            shortName: "ACE",
            description: "Validates deploying, monitoring, and managing solutions on Google Cloud Platform.",
            company: .gcp,
            repositoryURL: "https://github.com/Ditectrev/Google-Cloud-Platform-GCP-Associate-Cloud-Engineer-Practice-Tests-Exams-Questions-Answers",
            questionURL: "https://raw.githubusercontent.com/Ditectrev/Google-Cloud-Platform-GCP-Associate-Cloud-Engineer-Practice-Tests-Exams-Questions-Answers/main/README.md",
            url: "https://cloud.google.com/certification/cloud-engineer",
            exam: Exam(
                quick: ExamDetail(time: 40, questionCount: 20),
                intermediate: ExamDetail(time: 84, questionCount: 42),
                real: ExamDetail(time: 120, questionCount: 60)
            ),
            lastUpdate: nil
        )
    ]
}
